RSpec.describe Httpserver do
  describe Httpserver::Request do
    it "リクエストラインを正しくパースできる" do
      allow_any_instance_of(IO).to receive(:gets).and_return("GET /test.html HTTP/1.0") do
        request = Httpserver::Request.new(client)
        expect(request.method).to eq("GET")
        expect(request.uri).to eq("/test.html")
        expect(request.http_version).to eq("HTTP/1.0")
      end
    end

    it "リクエストラインが不正なときHttpErrorをraiseする" do
      allow_any_instance_of(IO).to receive(:gets).and_return("/test.html HTTP/1.0") do
        expect{ Httpserver::Request.new(client) }.to raise_error(HttpError)
      end
    end
  end
end
