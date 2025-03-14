# frozen_string_literal: true

require File.expand_path('../../../test_helper', __dir__)
require 'librarian/puppet/source/githubtarball'

describe Librarian::Puppet::Source::GitHubTarball::Repo do
  def assert_exact_error(klass, message)
    yield
  rescue Exception => e
    _(e.class).must_equal klass
    _(e.message).must_equal message
  else
    raise 'No exception was raised!'
  end

  class FakeResponse
    attr_accessor :code, :body

    def initialize(code, body)
      @code = code
      @body = body
    end

    def [](_key)
      nil
    end
  end

  describe '#api_call' do
    let(:environment) { Librarian::Puppet::Environment.new }
    let(:source) { Librarian::Puppet::Source::GitHubTarball.new(environment, 'foo') }
    let(:repo) { Librarian::Puppet::Source::GitHubTarball::Repo.new(source, 'bar') }
    let(:headers) { { 'User-Agent' => "librarian-puppet v#{Librarian::Puppet::VERSION}" } }
    let(:url) { 'https://api.github.com/foo?page=1&per_page=100' }
    let(:url_with_token) { 'https://api.github.com/foo?page=1&per_page=100&access_token=bar' }
    ENV['GITHUB_API_TOKEN'] = ''

    it 'succeeds' do
      response = []
      repo.expects(:http_get).with(url, { headers: headers }).returns(FakeResponse.new(200, JSON.dump(response)))
      _(repo.send(:api_call, '/foo')).must_equal(response)
    end

    it 'adds GITHUB_API_TOKEN if present' do
      ENV['GITHUB_API_TOKEN'] = 'bar'
      response = []
      repo.expects(:http_get).with(url_with_token,
                                   { headers: headers }).returns(FakeResponse.new(200, JSON.dump(response)))
      _(repo.send(:api_call, '/foo')).must_equal(response)
      ENV['GITHUB_API_TOKEN'] = ''
    end

    it 'fails when we hit api limit' do
      response = { 'message' => 'Oh boy! API rate limit exceeded!!!' }
      repo.expects(:http_get).with(url, { headers: headers }).returns(FakeResponse.new(403, JSON.dump(response)))
      message = 'Oh boy! API rate limit exceeded!!! -- increase limit by authenticating via GITHUB_API_TOKEN=your-token'
      assert_exact_error Librarian::Error, message do
        repo.send(:api_call, '/foo')
      end
    end

    it 'fails with unknown error message' do
      repo.expects(:http_get).with(url, { headers: headers }).returns(FakeResponse.new(403, ''))
      assert_exact_error Librarian::Error, "Error fetching #{url}: [403] " do
        repo.send(:api_call, '/foo')
      end
    end

    it 'fails with html' do
      repo.expects(:http_get).with(url, { headers: headers }).returns(FakeResponse.new(403, '<html>Oh boy!</html>'))
      assert_exact_error Librarian::Error, "Error fetching #{url}: [403] <html>Oh boy!</html>" do
        repo.send(:api_call, '/foo')
      end
    end

    it 'fails with unknown code' do
      repo.expects(:http_get).with(url, { headers: headers }).returns(FakeResponse.new(500, ''))
      assert_exact_error Librarian::Error, "Error fetching #{url}: [500] " do
        repo.send(:api_call, '/foo')
      end
    end
  end
end
