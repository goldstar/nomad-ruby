require "cgi"

require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Deployment} methods.
    # @return [Deployment]
    def deployment
      @deployment ||= Deployment.new(self)
    end
  end

  class Deployment < Request
    # List deployments.
    #
    # @param options [String] :prefix An optional prefix to filter
    #
    # @return [Array<Deployment>]
    def list(**options)
      json = client.get("/v1/deployments", options)
      return json.map { |item| Deploy.decode(item) }
    end

    # Read a specific deployment.
    #
    # @param [String] id The full ID of the deployment to read
    #
    # @return [Deployment]
    def read(id, **options)
      json = client.get("/v1/deployment/#{CGI.escape(id)}", options)
      return Deploy.decode(json)
    end

    # List allocation for given deployment.
    #
    # @param [String] id The full ID of the deployment to read
    #
    # @return [Array<DeployAlloc>]
    def allocations(id, **options)
      json = client.get("/v1/deployment/allocations/#{CGI.escape(id)}", options)
      return json.map { |item| DeployAlloc.decode(item) }
    end
  end


  class Deploy < Response
    # @!attribute [r] id
    #   The full deployment ID.
    #   @return [String]
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] namespace
    #   The namespace of the deployment.
    #   @return [String]
    field :Namespace, as: :namespace, load: :string_as_nil

    # @!attribute [r] job_id
    #   The name of the job for this deployment.
    #   @return [String]
    field :JobID, as: :job_id, load: :string_as_nil

    # @!attribute [r] task_groups
    #   The task groups for this deployment.
    #   @return [String]
    field :TaskGroups, as: :task_groups, load: ->(item) {
      (item || {}).inject({}) do |h,(k,v)|
        h[k.to_s] = DeploymentTaskGroup.decode(v)
        h
      end
    }

    # @!attribute [r] status
    #   The deployment status.
    #   @return [String]
    field :Status, as: :status, load: :string_as_nil

    # @!attribute [r] status_description
    #   The deployment status description.
    #   @return [String]
    field :StatusDescription, as: :status_description, load: :string_as_nil

    # @!attribute [r] job_create_index
    #   The job create index
    #   @return [Integer]
    field :JobCreateIndex, as: :job_create_index

    # @!attribute [r] job_modify_index
    #   The job modify index
    #   @return [Integer]
    field :JobModifyIndex, as: :job_modify_index

    # @!attribute [r] job_spec_modify_index
    #   The job spec modify index
    #   @return [Integer]
    field :JobSpecModifyIndex, as: :job_spec_modify_index

    # @!attribute [r] job_version
    #   The job version
    #   @return [Integer]
    field :JobVersion, as: :job_version

    # @!attribute [r] create_index
    #   The deployment create index
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] modify_index
    #   The deployment modify index.
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index
  end

  class DeploymentTaskGroup < Response

    # @!attribute [r] auto_revert
    #   If deployment autoreverted
    #   @return [Boolean]
    field :AutoRevert, as: :auto_revert

    # @!attribute [r] placed_allocs
    #   The desired number of canary allocs
    #   @return [Integer]
    field :DesiredCanaries, as: :desired_canaries

    # @!attribute [r] desired_total
    #   The desired number of allocs
    #   @return [Integer]
    field :DesiredTotal, as: :desired_total

    # @!attribute [r] healthy_allocs
    #   The number of healthy allocs
    #   @return [Integer]
    field :HealthyAllocs, as: :healthy_allocs

    # @!attribute [r] placed_allocs
    #   The number of placed allocs
    #   @return [Integer]
    field :PlacedAllocs, as: :placed_allocs

    # @!attribute [r] placed_canaries
    #   The number of placed canaries
    #   @return [Integer]
    field :PlacedCanaries, as: :placed_canaries

    # @!attribute [r] progress_deadline
    #   The progression deadline
    #   @return [String]
    field :ProgressDeadline, as: :progress_deadline, load: :nanoseconds_as_timestamp

    # @!attribute [r] promoted
    #   If deployment has been promoted
    #   @return [Boolean]
    field :Promoted, as: :promoted

    # @!attribute [r] require_progress_by
    #   The time the deployment must progress by
    #   @return [Timestamp]
    field :RequireProgressBy, as: :require_progress_by, load: :string_as_nil

    # @!attribute [r] unhealthy_allocs
    #   The number of unhealthy allocs
    #   @return [Integer]
    field :UnhealthyAllocs, as: :unhealthy_allocs
  end

  class DeployAlloc < Response
    # @!attribute [r] client_status
    #   The client allocation status.
    #   @return [String]
    field :ClientStatus, as: :client_status, load: :string_as_nil

    # @!attribute [r] client_description
    #   The client allocation description.
    #   @return [String]
    field :ClientDescription, as: :client_description, load: :string_as_nil

    # @!attribute [r] create_index
    #   The create index
    #   @return [Integer]
    field :CreateIndex, as: :create_index

    # @!attribute [r] create_time
    #   The time the allocation was created
    #   @return [Timestamp]
    field :CreateTime, as: :create_time, load: :nanoseconds_as_timestamp

    # @!attribute [r] deployment_status
    #   Deployment status
    #   @return [String]
    field :DeploymentStatus, as: :deployment_status, load: ->(item) { DeploymentStatus.decode(item) }

    # @!attribute [r] desired_description
    #   The desired allocation description.
    #   @return [String]
    field :DesiredDescription, as: :desired_description, load: :string_as_nil

    # @!attribute [r] desired_status
    #   The desired allocation status.
    #   @return [String]
    field :DesiredStatus, as: :desired_status, load: :string_as_nil

    # @!attribute [r] desired_transition
    #   Hash of what the allocation wants to do
    #   @return [Hash]
    field :DesiredTransition, as: :desired_transition, load: :stringify_keys

    # @!attribute [r] id
    #   The full allocation ID.
    #   @return [String]
    field :ID, as: :id, load: :string_as_nil

    # @!attribute [r] eval_id
    #   The full ID of the evaluation for this allocation.
    #   @return [String]
    field :EvalID, as: :eval_id, load: :string_as_nil

    # @!attribute [r] followup_eval_id
    #   Followup Eval ID
    #   @return [String]
    field :FollowupEvalID, as: :followup_eval_id, load: :string_as_nil

    # @!attribute [r] job_id
    #   The name of the job for this allocation.
    #   @return [String]
    field :JobID, as: :job_id, load: :string_as_nil

    # @!attribute [r] job_version
    #   Version of the job.
    #   @return [Integer]
    field :JobVersion, as: :job_version

    # @!attribute [r] modify_index
    #   The modify index
    #   @return [Integer]
    field :ModifyIndex, as: :modify_index

    # @!attribute [r] modify_time
    #   When alloc was modified
    #   @return [Timestamp]
    field :ModifyTime, as: :modify_time, load: :nanoseconds_as_duration

    # @!attribute [r] name
    #   The name of the job/allocation.
    #   @return [String]
    field :Name, as: :name, load: :string_as_nil

    # @!attribute [r] node_id
    #   The full ID of the node for this allocation.
    #   @return [String]
    field :NodeID, as: :node_id, load: :string_as_nil

    # @!attribute [r] reschedule_tracker
    #   Reschedule attempts tracker
    #   @return [Hash]
    field :RescheduleTracker, as: :reschedule_tracker, load: :stringify_keys

    # @!attribute [r] task_group
    #   The task group for this allocation.
    #   @return [String]
    field :TaskGroup, as: :task_group

    # @!attribute [r] task_states
    #   The list of task states for this allocation.
    #   @return [Hash<String,TaskState>]
    field :TaskStates, as: :task_states, load: ->(item) {
      (item || {}).inject({}) do |h,(k,v)|
        h[k.to_s] = TaskState.decode(v)
        h
      end
    }
  end

end
