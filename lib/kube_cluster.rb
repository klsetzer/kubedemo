require_relative 'aws_ops'
require_relative 'kube_aws'

class KubeCluster
  def initialize(cluster_name)
    @cluster_name = cluster_name
    @cfn_template_file = "#{@cluster_name}.stack-template.json"
    @cfn_client = AwsOps::Cfn.new
  end

  def create_cluster
    Dir.mkdir(@cluster_name)
    Dir.chdir(@cluster_name) do
      step('Initialize Kube config') { puts KubeAws.init(@cluster_name) }
      step('Fix cluster config')     { puts fix_cluster_config }
      step('Render CFN template')    { puts KubeAws.render }
      step('Validate config files')  { puts KubeAws.validate }
      step('Export CFN template')    { puts KubeAws.export_cfn_template }
      step('Fix CFN template')       { puts fix_cfn_template }
      File.symlink('../kube-creator', 'kube-creator')
      step('Create CFN stack')       { puts create_cfn_stack }
    end
  end

  private

  def create_cfn_stack
    stack_name = @cluster_name
    @cfn_client.create_stack(stack_name, @cfn_template_file)
    @cfn_client.assert_stack_status(stack_name, 'CREATE_COMPLETE')
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
