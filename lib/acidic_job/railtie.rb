# frozen_string_literal: true

require "rails/railtie"

module AcidicJob
  class Railtie < ::Rails::Railtie
    initializer "acidic_job.action_mailer_extension" do
      ::ActiveSupport.on_load(:action_mailer) do
        # Add `deliver_acidicly` to ActionMailer
        ::ActionMailer::Parameterized::MessageDelivery.include(Extensions::ActionMailer)
        ::ActionMailer::MessageDelivery.include(Extensions::ActionMailer)
      end
    end

    initializer "acidic_job.active_job_serializers" do
      ::ActiveSupport.on_load(:active_job) do
        require "active_job/serializers"
        require_relative "serializers/exception_serializer"
        require_relative "serializers/finished_point_serializer"
        require_relative "serializers/job_serializer"
        require_relative "serializers/range_serializer"
        require_relative "serializers/recovery_point_serializer"
        require_relative "serializers/worker_serializer"
        require_relative "serializers/active_kiq_serializer"
        require_relative "serializers/new_record_serializer"

        ::ActiveJob::Serializers.add_serializers(
          Serializers::ExceptionSerializer.instance,
          Serializers::NewRecordSerializer.instance,
          Serializers::FinishedPointSerializer.instance,
          Serializers::JobSerializer.instance,
          Serializers::RangeSerializer.instance,
          Serializers::RecoveryPointSerializer.instance,
          Serializers::WorkerSerializer.instance,
          Serializers::ActiveKiqSerializer.instance
        )
      end
    end

    # :nocov:
    generators do
      require "generators/acidic_job/install_generator"
    end
    # :nocov:

    # This hook happens after all initializers are run, just before returning
    config.after_initialize do
      if defined?(::Noticed)
        # Add `deliver_acidicly` to Noticed
        ::Noticed::Base.include(Extensions::Noticed)
      end
    end
  end
end
