RSpec.describe Httpserver do
  before do
    first_time = Time.at(0)
    allow(Time).to receive_message_chain(:now).and_return(first_time)
  end

  describe Httpserver::Header do
    let(:status_code) { 200 }
    let(:headers) { {} }
    let(:body_length) { "0" }
    let(:header) { Httpserver::Header.new(status_code, headers, body_length.to_s) }

    it "ヘッダーが生成できる" do
      header_lines = header.to_str.split("\n")
      expect(header_lines[0]).to eq("HTTP/1.0 200 OK")
      expect(header_lines[1]).to eq("Server: mimikyu")
      expect(header_lines[2]).to eq("Date: Thu, 01 Jan 1970 00:00:00 GMT")
      expect(header_lines[3]).to eq("Connection: close")
      expect(header_lines[4]).to eq("Content-Length: 0")
    end

    context "ステータスコードが400のとき" do
      let(:status_code) { 400 }
      it "Reason-PhraseがBad Requestになる" do
        header_lines = header.to_str.split("\n")
        expect(header_lines[0]).to eq("HTTP/1.0 400 Bad Request")
      end
    end

    context "Reason-Phraseがステータスコードが404のとき" do
      let(:status_code) { 404 }
      it "Not Foundになる" do
        header_lines = header.to_str.split("\n")
        expect(header_lines[0]).to eq("HTTP/1.0 404 Not Found")
      end
    end

    context "ステータスコードが500のとき" do
      let(:status_code) { 500 }
      it "Reason-PhraseがInternal Server Errorになる" do
        header_lines = header.to_str.split("\n")
        expect(header_lines[0]).to eq("HTTP/1.0 500 Internal Server Error")
      end
    end

    context "Context-typeを追加したとき" do
      let(:headers) { {"Content-Type" => "text/html"} }
      it "Context-typeがヘッダーに含まれる" do
        header_lines = header.to_str.split("\n")
        expect(header_lines[5]).to eq("Content-Type: text/html")
      end
    end

    context "Serverを上書きしたとき" do
      let(:headers) { {"Server" => "finfin"} }
      it "Serverが指定した値に上書きされる" do
        header_lines = header.to_str.split("\n")
        expect(header_lines[1]).to eq("Server: finfin")
      end
    end
  end

  describe Httpserver::Response do
    before do
      stub_const("Httpserver::Response::DOCUMENT_ROOT", "/Users/yuka/GoogleDrive/Study/httpserver/spec/res")
    end

    let(:status_code) { 200 }
    let(:text) { "test" }

    it "文字列からレスポンスを生成できる" do
      lines = Httpserver::Response.new.text(status_code, text).split("\n")
      expect(lines[4]).to eq("Content-Length: " + text.length.to_s)
      expect(lines[5]).to eq("Content-Type: text/html")
      expect(lines[6]).to eq("")
      expect(lines[7]).to eq("test")
    end

    it "htmlファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.html")

      lines = Httpserver::Response.new.build(request).split("\n")
      expect(lines[5]).to eq("Content-Type: text/html")
      expect(lines[6]).to eq("")
      expect(lines[7]).to eq("test.html")
    end

    it "cssファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.css")

      lines = Httpserver::Response.new.build(request).split("\n")
      expect(lines[5]).to eq("Content-Type: text/css")
      expect(lines[6]).to eq("")
      expect(lines[7]).to eq("test.css")
    end

    it "jpegファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.jpeg")

      lines = Httpserver::Response.new.build(request).split("\n")
      expect(lines[5]).to eq("Content-Type: image/jpeg")
      expect(lines[6]).to eq("")
      expect(lines[7]).to eq("test.jpeg")
    end

    it "ファイルが存在しないときHttpErrorをraiseする" do
      request = Object.new
      allow(request).to receive(:uri).and_return("notfound.test")
      expect{ Httpserver::Response.new.build(request) }.to raise_error(Httpserver::HttpError)
    end

    it "特殊な拡張子のときContent-Typeヘッダーを挿入しない" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.abcd")

      lines = Httpserver::Response.new.build(request).split("\n")
      expect(lines[5]).to eq("")
      expect(lines[6]).to eq("test.abcd")
    end

    it "エラーオブジェクトからレスポンスを生成できる" do
      lines = Httpserver::Response.new.error(Httpserver::HttpError.new(500)).split("\n")
      expect(lines[0]).to eq("HTTP/1.0 500 Internal Server Error")
      expect(lines[5]).to eq("Content-Type: text/html")
      expect(lines[6]).to eq("")
      expect(lines[7]).to eq("Internal Server Error")
    end
  end
end
