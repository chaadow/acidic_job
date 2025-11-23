# frozen_string_literal: true

require "active_job/serializers/object_serializer"

module AcidicJob
  module Serializers
    class WorkerSerializer < ::ActiveJob::Serializers::ObjectSerializer
      def serialize(worker)
        super(
          "job_class" => worker.class.name
        )
      end

      def deserialize(hash)
        worker_class = hash["job_class"].constantize
        worker_class.new
      end

      def serialize?(argument)
        defined?(::Sidekiq) && argument.class.include?(::Sidekiq::Worker) &&
          !(defined?(::AcidicJob::ActiveKiq) && argument.class < ::AcidicJob::ActiveKiq)
      end

      def klass
        '::AcidicJob::ActiveKiq'
      end
    end
  end
end
