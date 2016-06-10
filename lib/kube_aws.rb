class KubeAws
  def self.init(cluster_name)
    %x{
    kube-aws init --cluster-name=#{cluster_name} \
    --external-dns-name=#{cluster_name}.aws.liquidchicken.org \
    --region=us-east-1 \
    --availability-zone=us-east-1c \
    --key-name=lc-us-east-1 \
    --kms-key-arn="arn:aws:kms:us-east-1:437443400885:key/819a0470-5371-4217-942e-86abd5e3c979"
    }
  end

  def self.render
    %x{ kube-aws render }
  end

  def self.validate
    %x{ kube-aws validate }
  end

  def self.export_cfn_template
    %x{ kube-aws up --export }
  end
end

def usage
  puts 'create_kube_cluster <cluster_name>'
  puts '  KUBE_CLUSTER_NAME environment variable must be set'
end

