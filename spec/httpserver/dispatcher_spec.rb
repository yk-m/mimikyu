RSpec.describe Httpserver do
  before do
    first_time = Time.at(0)
    allow(Time).to receive_message_chain(:now).and_return(first_time)
  end

  let(:response_lines) { Httpserver::Dispatcher.new.run(Object.new).split("\n") }

  describe Httpserver::Dispatcher do
    let(:request_line) { method + " /test.html HTTP/1.0" }

    context "メソッドがGETのとき" do
      let(:method) { "GET" }
      it "正しいHTTP Responseを返せる" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Httpserver::Response).to receive(:file).and_return(["status\n", "header\n", "body"])
        expect(response_lines[0]).to eq("status")
        expect(response_lines[1]).to eq("header")
        expect(response_lines[2]).to eq("")
        expect(response_lines[3]).to eq("body")
      end

      it "HTTPErrorがraiseされたときエラーが返却される" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Httpserver::Response).to receive(:file).and_raise(Httpserver::HttpError, 500)
        text = "Internal Server Error"
        expect(response_lines[0]).to eq("HTTP/1.0 500 Internal Server Error")
        expect(response_lines[1]).to eq("Server: mimikyu")
        expect(response_lines[2]).to eq("Date: Thu, 01 Jan 1970 00:00:00 GMT")
        expect(response_lines[3]).to eq("Connection: close")
        expect(response_lines[4]).to eq("Content-Length: " + text.length.to_s)
        expect(response_lines[5]).to eq("Content-Type: text/html")
        expect(response_lines[6]).to eq("")
        expect(response_lines[7]).to eq(text)
      end
    end

    context "メソッドがHEADのとき" do
      let(:method) { "HEAD" }
      it "正しいHTTP Responseを返せる" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Httpserver::Response).to receive(:file).and_return(["status\n", "header\n", "body"])
        expect(response_lines[0]).to eq("status")
        expect(response_lines[1]).to eq("header")
        expect(response_lines[2]).to be nil
        expect(response_lines[3]).to be nil
      end

      it "HTTPErrorがraiseされたときエラーが返却される" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Httpserver::Response).to receive(:file).and_raise(Httpserver::HttpError, 500)
        expect(response_lines[6]).to be nil
      end
    end
  end
end
