class Kubectl
  def self.get_nodes
    %x{ kubectl --kubeconfig=kubeconfig get nodes }
  end

  def self.cluster_info
    %x{ kubectl --kubeconfig=kubeconfig cluster-info }
  end
end

