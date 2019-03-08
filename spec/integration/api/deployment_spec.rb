require "spec_helper"

module Nomad
  describe Deployment do
    subject { nomad_test_client.deployment }

    before(:all) {
      jobfile = File.read(File.expand_path("../../../support/jobs/deployment.job.json", __FILE__))
      nomad_test_client.post("/v1/jobs", jobfile)
    }

    describe "#list" do
      it "lists all deployments" do
        result = subject.list
        expect(result).to be_a(Array)
        expect(result.size).to be >= 1
        expect(result[0]).to be_a(Deploy)
      end

      it "filters on prefix" do
        list = subject.list
        deploy_id = list.first.id.split("-", 2)[0]
        result = subject.list(prefix: deploy_id)
        expect(result[0]).to be_a(Deploy)
        expect(result).to include(list[0])
      end
    end

    describe "#read" do
      it "reads a specific deployment" do
        list = subject.list
        id = list.select { |x| x.job_id == 'deployment' }[0].id
        result = subject.read(id)
        loop do
          puts result
          if result.status != "pending"
            break
          else
            sleep 0.25
            result = subject.read(id)
          end
        end
        aggregate_failures do
          expect(result).to be
          expect(result.status).to be
          expect(result.job_id).to be
          expect(result.id).to eq(id)
          expect(result).to respond_to(:status_description)
          expect(result).to respond_to(:job_id)
          expect(result.job_id).to eq("deployment")
          expect(result.job_create_index).to be_a(Integer)
          expect(result.job_modify_index).to be_a(Integer)
          expect(result.job_version).to be_a(Integer)
          expect(result.job_spec_modify_index).to be_a(Integer)
          expect(result.task_groups).to be_a(Hash)
          expect(result.task_groups["deployment"]).to be_a(Nomad::DeploymentTaskGroup)
        end
      end
    end

    describe "#allocations" do
      it "gets a list of allocations for this deployment" do
        list = subject.list
        id = list[0].id
        result = subject.allocations(id)
        loop do
          deployment_status = subject.read(id).status
         # require 'pry'; binding.pry
          if ( !result.empty? && result[0].client_status != "pending") ||
              deployment_status != "running"
            break
          else
            sleep 1.5
            result = subject.allocations(id)
          end
        end
        alloc = result[0]
        aggregate_failures do
          expect(result).to be
          expect(alloc).to be_a(DeployAlloc)
          expect(alloc.client_status).to eq("running")
        end
      end
    end

  end
end
