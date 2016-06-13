class KubeAws
  def self.init(cluster_name:, az:, ssh_key_name:, kms_key_arn:)
    region = az.chop
    %x{
    kube-aws init --cluster-name=#{cluster_name} \
    --external-dns-name=#{cluster_name}.aws.liquidchicken.org \
    --region=#{region} \
    --availability-zone=#{az} \
    --key-name=#{ssh_key_name} \
    --kms-key-arn="#{kms_key_arn}"
    }
  end

  def self.destroy
    %x{ kube-aws destroy }
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
