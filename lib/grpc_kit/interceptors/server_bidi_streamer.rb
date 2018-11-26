# frozen_string_literal: true

require 'grpc_kit/interceptors'

module GrpcKit
  module Interceptors::Server
    class BidiStreamer < Streaming
      # @param interceptor [GrpcKit::GRPC::ServerInterceptor]
      # @param call [GrpcKit::Calls::Client::BidiStreamer]
      def invoke(interceptor, call)
        interceptor.bidi_streamer(call: call, method: call.method) do
          yield(call)
        end
      end
    end
  end
end