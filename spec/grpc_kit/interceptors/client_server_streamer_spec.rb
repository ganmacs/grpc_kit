# frozen_string_literal: true

require 'grpc_kit/grpc/interceptor'
require 'grpc_kit/interceptors/client_server_streamer'

RSpec.describe GrpcKit::Interceptors::Client::ServerStreamer do
  let(:interceptor) { described_class.new }
  let(:interceptors) { [interceptor1, interceptor2] }
  let(:method) { double(:method) }
  let(:call) { double(:call, method: method) }
  let(:metadata) { double(:metadata) }
  let(:queue) { [] }

  let(:interceptor1) do
    Class.new(GrpcKit::GRPC::ClientInterceptor) do
      def initialize(queue)
        @queue = queue
      end

      def server_streamer(*)
        @queue.push(:interceptor1)
        yield
      end
    end.new(queue)
  end

  let(:interceptor2) do
    Class.new(GrpcKit::GRPC::ClientInterceptor) do
      def initialize(queue)
        @queue = queue
      end

      def server_streamer(*)
        @queue.push(:interceptor2)
        yield
      end
    end.new(queue)
  end

  before do
    interceptor.interceptors = interceptors
  end

  it "call all interceptors's server_streamer" do
    expect(interceptor1).to receive(:server_streamer).with(request: nil, call: call, method: method, metadata: metadata).once.and_call_original
    expect(interceptor2).to receive(:server_streamer).with(request: nil, call: call, method: method, metadata: metadata).once.and_call_original

    ret = interceptor.intercept(call, metadata) do |c, m|
      [c, m].tap { |rv| expect(rv).to eq([call, metadata]) }
    end
    expect(ret).to eq([call, metadata])
    expect(queue).to eq(%i[interceptor2 interceptor1])
  end

  context 'when given interceptor is empty' do
    let(:interceptors) { [] }

    it "do not call interceptor's server_streamer" do
      expect(interceptor1).not_to receive(:server_streamer)
      expect(interceptor2).not_to receive(:server_streamer)

      ret = interceptor.intercept(call, metadata) do |c, m|
        [c, m].tap { |rv| expect(rv).to eq([call, metadata]) }
      end
      expect(ret).to eq([call, metadata])
    end
  end
end