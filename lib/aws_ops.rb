module AwsOps
  class Cfn
    def initialize(opts = {})
      @opts = opts
      @cfn_client = Aws::CloudFormation::Client.new
    end

    def create_stack(stack_name, template_file)
      puts "Using CloudFormation template #{template_file}"
      template_body = IO.read(template_file)

      @cfn_client.create_stack({
        stack_name: stack_name,
        template_body: template_body,
        disable_rollback: true,
        capabilities: ["CAPABILITY_IAM"], # accepts CAPABILITY_IAM
      })
    end

    def stack_info(stack_name)
      stacks = @cfn_client.list_stacks({ stack_status_filter: ["CREATE_IN_PROGRESS", "CREATE_FAILED", "CREATE_COMPLETE"] }).stack_summaries
      stacks.select { |st| st.stack_name == stack_name }.first
    end

    def assert_stack_status(stack_name, desired_status)
      sleep_time = 60
      for i in 1..20
        stack_status = stack_info(stack_name)[:stack_status]
        printf("%-25s [%2s]\n", "Stack: #{stack_name} is #{stack_status}", i)
        return if stack_status == desired_status
        sleep(sleep_time -= 4)
      end
      puts "CFN stack creation failed"
    end
  end
end
