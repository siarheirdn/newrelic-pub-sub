namespace :podhealth do
  desc "Check StatefulSet and Pod health"
  task :check_health, [:st_name, :st_namespace] do |t, args|
    st_name = args[:st_name]
    st_namespace = args[:st_namespace]

    running = 0
    waiting = 0
    success = 0
    failed = 0

    kubectl_output = `kubectl describe statefulset #{st_name} -n #{st_namespace}`
    pods_status_line = kubectl_output.lines.grep(/Pods Status:/).first

    running = pods_status_line.split(":")[1].split("/")[0].to_i
    waiting = pods_status_line.split(":")[1].split("/")[1].to_i
    success = pods_status_line.split(":")[1].split("/")[2].to_i
    failed = pods_status_line.split(":")[1].split("/")[3].to_i

    if running != 0 && waiting == 0 && success == 0 && failed == 0
      puts "Status is ok"
    else
      puts "Status is not ok"
      # exit 1
    end

    date_time_orig = kubectl_output.lines.grep(/CreationTimestamp/).first.split(",")[1].strip
    date_time = date_time_orig.strip
    formatted_date = Time.parse(date_time).strftime("%Y-%m-%d %H:%M:%S %z")
    current_time = Time.now.to_i
    formatted_timestamp = Time.parse(formatted_date).to_i
    time_diff = current_time - formatted_timestamp
    puts time_diff

    if time_diff > 600
      puts "Deployment date is too old for new deployment"
      # exit 1
    end

    age = `kubectl get pods -n #{st_namespace} | grep #{st_name} | awk '{print $5}'`

    time_in_seconds = age.scan(/(\d+)([a-zA-Z]+)/).sum do |value, unit|
      case unit
      when "d"
        value.to_i * 86400
      when "h"
        value.to_i * 3600
      when "m"
        value.to_i * 60
      else
        0
      end
    end

    current_timestamp = Time.now.to_i
    time_difference = current_timestamp - time_in_seconds

    puts "Time difference in seconds: #{time_difference} seconds"

    if time_difference > 600
      puts "Pod looks too old for new deployment"
      # exit 1
    end
  end
end
