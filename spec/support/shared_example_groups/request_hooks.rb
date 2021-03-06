shared_examples_for "request hooks" do |library_hook_name|
  let(:request_url) { "http://localhost:#{VCR::SinatraApp.port}/foo" }

  before(:each) do
    # ensure that all the other library hooks are disabled so that we don't
    # get double-hookage (such as for WebMock and Typhoeus both invoking the
    # hooks for a typhoeus request)
    VCR.library_hooks.stub(:disabled?) { |lib_name| lib_name != library_hook_name }
  end

  def make_request(disabled = false)
    make_http_request(:get, request_url)
  end

  def assert_expected_response(response)
    response.status.code.should eq(200)
    response.body.should eq('FOO!')
  end

  [:before_http_request, :after_http_request].each do |hook|
    specify "the #{hook} hook is only called once per request" do
      call_count = 0
      VCR.configuration.send(hook) { |r| call_count += 1 }

      make_request
      call_count.should eq(1)
    end

    specify "the #{hook} hook yields the request" do
      request = nil
      VCR.configuration.send(hook) { |r| request = r }

      make_request
      request.method.should be(:get)
      request.uri.should eq(request_url)
    end

    specify "the #{hook} hook is not called if the library hook is disabled" do
      VCR.library_hooks.should respond_to(:disabled?)
      VCR.library_hooks.stub(:disabled? => true)

      hook_called = false
      VCR.configuration.send(hook) { |r| hook_called = true }

      make_request(:disabled)
      hook_called.should be_false
    end
  end

  specify "the after_http_request hook yields the response if there is one and the second block arg is given" do
    response = nil
    VCR.configuration.after_http_request { |req, res| response = res }

    make_request
    assert_expected_response(response)
  end
end

