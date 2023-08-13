RSpec.describe Mimikyu do
  before do
    first_time = Time.at(0)
    allow(Time).to receive_message_chain(:now).and_return(first_time)
  end

  describe Mimikyu::StatusLine do
    let(:status_code) { 200 }
    let(:status_line) { Mimikyu::StatusLine.new.build(status_code) }

    context "ステータスコードが200のとき" do
      let(:status_code) { 200 }
      it "Reason-PhraseがOKになる" do
        expect(status_line).to eq("HTTP/1.0 200 OK\n")
      end
    end

    context "ステータスコードが400のとき" do
      let(:status_code) { 400 }
      it "Reason-PhraseがBad Requestになる" do
        expect(status_line).to eq("HTTP/1.0 400 Bad Request\n")
      end
    end

    context "ステータスコードが404のとき" do
      let(:status_code) { 404 }
      it "Reason-PhraseがNot Foundになる" do
        expect(status_line).to eq("HTTP/1.0 404 Not Found\n")
      end
    end

    context "ステータスコードが500のとき" do
      let(:status_code) { 500 }
      it "Reason-PhraseがInternal Server Errorになる" do
        expect(status_line).to eq("HTTP/1.0 500 Internal Server Error\n")
      end
    end
  end

  describe Mimikyu::Header do
    let(:status_code) { 200 }
    let(:body_length) { "0" }
    let(:header) { Mimikyu::Header.new.build }

    it "ヘッダーが生成できる" do
      header_lines = header.split("\n")
      expect(header_lines[0]).to eq("Server: mimikyu")
      expect(header_lines[1]).to eq("Date: Thu, 01 Jan 1970 00:00:00 GMT")
      expect(header_lines[2]).to eq("Connection: close")
      expect(header_lines[3]).to eq("Content-Length: 0")
    end

    context "Context-typeを追加したとき" do
      let(:header) {
        h = Mimikyu::Header.new
        h.set_content_type("text/html")
        h.build
      }
      it "Context-typeがヘッダーに含まれる" do
        header_lines = header.split("\n")
        expect(header_lines[4]).to eq("Content-Type: text/html")
      end
    end

    context "Serverを上書きしたとき" do
      let(:header) {
        h = Mimikyu::Header.new
        h.set("Server", "finfin")
        h.build
      }
      it "Serverが指定した値に上書きされる" do
        header_lines = header.split("\n")
        expect(header_lines[0]).to eq("Server: finfin")
      end
    end
  end

  describe Mimikyu::Response do
    before do
      stub_const("Mimikyu::Response::DOCUMENT_ROOT", File.join(Dir.pwd, "spec/res"))
      stub_const("Mimikyu::Response::CGI_ROOT", File.join(Dir.pwd, "spec/res"))
    end

    let(:status_code) { 200 }
    let(:text) { "test" }

    it "文字列からレスポンスを生成できる" do
      status_line, header, body = Mimikyu::Response.new.text(status_code, text)
      header = header.split("\n")
      expect(header[3]).to eq("Content-Length: " + text.length.to_s)
      expect(header[4]).to eq("Content-Type: text/html")
      expect(body).to eq(text)
    end

    it "htmlファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.html")
      status_line, header, body = Mimikyu::Response.new.file(request)
      header = header.split("\n")
      expect(header[4]).to eq("Content-Type: text/html")
      expect(body).to eq("test.html\n")
    end

    it "cssファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.css")

      status_line, header, body = Mimikyu::Response.new.file(request)
      header = header.split("\n")
      expect(header[4]).to eq("Content-Type: text/css")
      expect(body).to eq("test.css\n")
    end

    it "jpegファイルからレスポンスを生成できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.jpeg")

      status_line, header, body = Mimikyu::Response.new.file(request)
      header = header.split("\n")
      expect(header[4]).to eq("Content-Type: image/jpeg")
      expect(body).to eq("test.jpeg\n")
    end

    it "ファイルが存在しないときHttpErrorをraiseする" do
      request = Object.new
      allow(request).to receive(:uri).and_return("notfound.test")
      expect{ Mimikyu::Response.new.file(request) }.to raise_error(Mimikyu::HttpError)
    end

    it "特殊な拡張子のときContent-Typeヘッダーを挿入しない" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.abcd")

      status_line, header, body = Mimikyu::Response.new.file(request)
      expect(header).to_not include "Content-Type"
      expect(body).to eq("test.abcd\n")
    end

    it "Pythonが実行できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.py")

      status_line, header, body = Mimikyu::Response.new.cgi(request)
      expect(header).to eq("\nsys.version_info(major=3, minor=5, micro=3, releaselevel='final', serial=0)\n")
    end

    it "Rubyが実行できる" do
      request = Object.new
      allow(request).to receive(:uri).and_return("test.rb")

      status_line, header, body = Mimikyu::Response.new.cgi(request)
      expect(header).to eq("\n2.3.3\n")
    end
  end
end
