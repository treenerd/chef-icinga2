# resource
class Chef
  class Resource
    # provides icinga2_envhostgroup
    class Icinga2Envhostgroup < Chef::Resource
      identity_attr :name

      def initialize(name, run_context = nil)
        super
        @resource_name = :icinga2_envhostgroup if respond_to?(:resource_name)
        @provides = :icinga2_envhostgroup
        @provider = Chef::Provider::Icinga2Envhostgroup
        @action = :create
        @allowed_actions = [:create, :delete, :nothing]
        @name = name
      end

      def environment(arg = nil)
        set_or_return(
          :environment, arg,
          :kind_of => String,
          :default => @name
        )
      end

      def groups(arg = nil)
        set_or_return(
          :groups, arg,
          :kind_of => Array,
          :default => []
        )
      end
    end
  end
end

# provider
class Chef
  class Provider
    # provides icinga2_envhostgroup
    class Icinga2Envhostgroup < Chef::Provider::LWRPBase
      provides :icinga2_envhostgroup if respond_to?(:provides)

      def whyrun_supported?
        true
      end

      action :create do
        new_resource.updated_by_last_action(object_template)
      end

      action :delete do
        new_resource.updated_by_last_action(object_template)
      end

      protected

      def object_template
        resource_name = new_resource.resource_name.to_s.gsub('icinga2_', '')
        ot = template ::File.join(node['icinga2']['objects_dir'], "#{resource_name}_#{new_resource.environment}.conf") do
          source "object.#{resource_name}.conf.erb"
          cookbook 'icinga2'
          owner node['icinga2']['user']
          group node['icinga2']['group']
          mode 0640
          variables(:environment => new_resource.environment, :groups => new_resource.groups)
          notifies :reload, 'service[icinga2]', :delayed
        end
        ot.updated?
      end
    end
  end
end
