require_relative 'aws_ops'
require_relative 'kube_aws'

class KubeCluster
  def initialize(cluster_name)
    @cluster_name = cluster_name
    @cfn_template_file = "#{@cluster_name}.stack-template.json"
    @kms_key_arn = 'arn:aws:kms:us-east-1:437443400885:key/819a0470-5371-4217-942e-86abd5e3c979'
  end

  def create_cluster
    Dir.mkdir(@cluster_name)
    Dir.chdir(@cluster_name) do
      step('Initialize Kube config') { puts KubeAws.init(cluster_name: @cluster_name, az: 'us-east-1c', ssh_key_name: 'lc-us-east-1', kms_key_arn: @kms_key_arn) }
      step('Fix cluster config')     { puts fix_cluster_config }
      step('Render CFN template')    { puts KubeAws.render }
      step('Validate config files')  { puts KubeAws.validate }
      step('Export CFN template')    { puts KubeAws.export_cfn_template }
      step('Fix CFN template')       { puts fix_cfn_template }
      step('Create CFN stack')       { puts create_cfn_stack }
      step('Start kubectl proxy')    { puts start_kubectl_proxy }
    end
  end

  def destroy_cluster
    Dir.chdir(@cluster_name) do
      step('Kill kubectl proxy')     { puts kill_kubectl_proxy }
      step('Remove kube cluster')    { puts KubeAws.destroy }
    end
  end

  private

  def start_kubectl_proxy
    puts 'start proxy'
  end

  def kill_kubectl_proxy
    puts 'kill proxy'
  end

  def create_cfn_stack
    stack_name = @cluster_name
    cfn_client = AwsOps::Cfn.new
    cfn_client.create_stack(stack_name, @cfn_template_file)
    cfn_client.assert_stack_status(stack_name, 'CREATE_COMPLETE')
  end

  def fix_cfn_template
    @cfn = JSON.parse(IO.read(@cfn_template_file))
    @cfn['Description'] = "kube demo #{@cluster_name}"
    @cfn['Resources']['AutoScaleWorker']['Properties']['MinSize'] = "1"
    @cfn['Resources']['AutoScaleWorker']['Properties']['DesiredCapacity'] = "1"
    @cfn['Resources']['AutoScaleWorker']['UpdatePolicy']['AutoScalingRollingUpdate']['MinInstancesInService'] = "1"
    File.open(@cfn_template_file, "w") { |file| file.write JSON.pretty_generate(@cfn) }
    "#{@cfn['Resources'].count} resources in CFN template"
  end

  def config
    @config ||= YAML.load_file('cluster.yaml')
  end

  def fix_cluster_config
    config['createRecordSet'] = true
    config['hostedZone'] = 'aws.liquidchicken.org'
    config['recordSetTTL'] = 60
    config['workerCount'] = 12
    File.open('cluster.yaml', "w") { |file| file.write config.to_yaml }
    config.to_yaml
  end

  def step(name)
    @step_num ||= 1
    puts Rainbow("===> Step[#{@step_num}]: #{name}").blue
    yield
    puts "\n\n"
    @step_num += 1
  end
end
