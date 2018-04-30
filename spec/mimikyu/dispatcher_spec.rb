RSpec.describe Mimikyu do
  before do
    first_time = Time.at(0)
    allow(Time).to receive_message_chain(:now).and_return(first_time)
  end

  describe Mimikyu::Dispatcher do
    let(:request_line) { method + " " + uri + " HTTP/1.0" }
    let(:uri) { "/test.html" }

    context "メソッドがGETのとき" do
      let(:method) { "GET" }
      it "正しいHTTP Responseを返せる" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Mimikyu::Response).to receive(:file).and_return(["status\n", "header\n", "body"])
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        expect(response_lines[0]).to eq("status")
        expect(response_lines[1]).to eq("header")
        expect(response_lines[2]).to eq("")
        expect(response_lines[3]).to eq("body")
      end

      it "HTTPErrorがraiseされたらエラーが返却される" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Mimikyu::Response).to receive(:file).and_raise(Mimikyu::HttpError, 400)
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        text = "Bad Request"
        expect(response_lines[0]).to eq("HTTP/1.0 400 Bad Request")
        expect(response_lines[1]).to eq("Server: mimikyu")
        expect(response_lines[2]).to eq("Date: Thu, 01 Jan 1970 00:00:00 GMT")
        expect(response_lines[3]).to eq("Connection: close")
        expect(response_lines[4]).to eq("Content-Length: " + text.length.to_s)
        expect(response_lines[5]).to eq("Content-Type: text/html")
        expect(response_lines[6]).to eq("")
        expect(response_lines[7]).to eq(text)
      end

      it "HTTPError以外の例外がraiseされたら500を返す" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Mimikyu::Response).to receive(:file).and_raise(Mimikyu::HttpError, 500)
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        text = "Internal Server Error"
        expect(response_lines[0]).to eq("HTTP/1.0 500 Internal Server Error")
        expect(response_lines[7]).to eq(text)
      end
    end

    context "存在しないファイルを指定されたら" do
      let(:method) { "GET" }
      let(:uri) { "/not_exists.html" }
      it "404を返す" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        text = "Not Found"
        expect(response_lines[0]).to eq("HTTP/1.0 404 Not Found")
        expect(response_lines[7]).to eq(text)
      end
    end

    # context "読み込み権限のないファイルを指定されたら" do
    #   let(:method) { "GET" }
    #   let(:uri) { "/test_permissions.html" }
    #   it "500を返す" do
    #     allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
    #     response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
    #     text = "Internal Server Error"
    #     expect(response_lines[0]).to eq("HTTP/1.0 500 Internal Server Error")
    #     expect(response_lines[7]).to eq(text)
    #   end
    # end

    context "メソッドがHEADのとき" do
      let(:method) { "HEAD" }
      it "正しいHTTP Responseを返せる" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Mimikyu::Response).to receive(:file).and_return(["status\n", "header\n", "body"])
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        expect(response_lines[0]).to eq("status")
        expect(response_lines[1]).to eq("header")
        expect(response_lines[2]).to be nil
        expect(response_lines[3]).to be nil
      end

      it "HTTPErrorがraiseされたときエラーが返却される" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        allow_any_instance_of(Mimikyu::Response).to receive(:file).and_raise(Mimikyu::HttpError, 500)
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        expect(response_lines[6]).to be nil
      end
    end

    context "メソッドがPOSTのとき" do
      let(:method) { "POST" }
      it "405エラーを返す" do
        allow_any_instance_of(Object).to receive(:gets).and_return(request_line)
        response_lines = Mimikyu::Dispatcher.new.run(Object.new).split("\n")
        expect(response_lines[0]).to eq("HTTP/1.0 405 Method Not Allowed")
      end
    end

    context "例外が投げられたとき" do
      it "500エラーを返す" do
        allow_any_instance_of(Mimikyu::Request).to receive(:new).and_raise()
      end
    end
  end
end
