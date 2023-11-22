namespace :podhealth do
    desc "Log into GCP with a key"
    task :check_pod_health => [:"login:gke", :"kubeconfig:configure_kubectl"] do
        include Dhdevops::Kubectl

        successful_deployment = false
        number_of_retries = 60

        number_of_retries.times { |i|

          puts("Running check for the #{i+1} time(s) out of #{number_of_retries}")

          desired = get_desired_number_of_pods()
          replicas = get_actual_number_of_pods()
          updatedReplicas = get_number_of_updated_replicas()
          readyReplicas = get_number_of_ready_replicas()
          availableReplicas = get_number_of_available_replicas()

          puts("desired: #{desired}")
          puts("actual: #{replicas}")
          puts("updated: #{updatedReplicas}")
          puts("ready: #{readyReplicas}")
          puts("available: #{availableReplicas}")

          if desired == replicas && replicas == updatedReplicas && updatedReplicas == readyReplicas && readyReplicas == availableReplicas

            pods = Array.new()
            number_of_retries.times {
              break if pods.length() == desired
                pods = get_pods_not_spun_up_by_jobs()
                sleep(1)
            }

            puts(pods)

            pods.each do |pod|
                appVersion = get_pod_image(pod, $configuration)[1]
                if appVersion == ENV['APP_VERSION']
                  puts("Pod #{pod} has the desired version of an image")
                  successful_deployment = true
                else
                  successful_deployment = false
                  raise GaudiError, "There is a mismatch between the desired version of an image and the actual image in one of the pods. Please investigate"
                end
            end
            break
          end
          sleep(1)
        }

        if successful_deployment == false
          raise GaudiError, "There seems to be something wrong with the deployment. Likely a mismatch in desired number od pods vs actual one. Please investigate"
        end
    end
end
