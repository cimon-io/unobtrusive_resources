# frozen_string_literal: true

require 'unobtrusive_resources/version'
require 'active_support/concern'
require 'active_support/lazy_load_hooks'

module UnobtrusiveResources
  extend ActiveSupport::Concern
  # required methods
  #  :relationship_name
  #  :resource_class
  #  :find_for_create_by
  #  :permitted_params_key
  #  :permitted_params_create_value
  #  :permitted_params_update_value

  #  :parent_class
  #  :parent_permitted_params_key
  included do
    private_class_method :unobtrusive_method
    private_class_method :safe_unobtrusive_method
  end

  class_methods do
    def unobtrusive_method(method_name, &block)
      return method_name if private_method_defined?(method_name)
      return method_name if method_defined?(method_name)

      define_method(method_name, &block)
      protected method_name
    end

    def safe_unobtrusive_method(method_name, value)
      if value.respond_to?(:call)
        unobtrusive_method(method_name, &value)
      else
        unobtrusive_method(method_name) { value }
      end
    end

    def unobtrusive(options)
      helper_method :resource,
                    :resource_class,
                    :resource_name,
                    :resource_collection_name,
                    :resource_route,
                    :resource_url,
                    :new_resource_url,
                    :edit_resource_url,
                    :collection,
                    :collection_route,
                    :collection_url

      options.each do |key, value|
        safe_unobtrusive_method(key, value)
      end

      unobtrusive_method :collection do
        instance_variable_set(:@_collection, end_of_association_chain) unless instance_variable_defined?(:@_collection)
        instance_variable_get(:@_collection)
      end

      unobtrusive_method :resource do
        instance_variable_set(:@_resource, end_of_association_chain.public_send(finder_method, unobtrusive_params[finder_param])) unless instance_variable_defined?(:@_resource)
        instance_variable_get(:@_resource)
      end

      unobtrusive_method :build_resource do
        instance_variable_set(:@_resource, end_of_association_chain.build)
        instance_variable_get(:@_resource).assign_attributes(build_permitted_params)
        instance_variable_get(:@_resource)
      end

      unobtrusive_method :find_or_create_resource do
        instance_variable_set(
          :@_resource,
          end_of_association_chain.find_by(find_for_create_by => permitted_params[find_for_create_by]) || end_of_association_chain.build.tap { |r| r.update(permitted_params) }
        )
      end

      unobtrusive_method :create_resource do
        instance_variable_set(
          :@_resource,
          end_of_association_chain.build.tap { |r| r.update(permitted_params) }
        )
      end

      unobtrusive_method :update_resource do
        resource.update(permitted_params)
      end

      unobtrusive_method :destroy_resource do
        resource.destroy
      end

      unobtrusive_method :association_chain do
        begin_of_association_chain.public_send(relationship_name)
      end

      unobtrusive_method :association_chain_with_accessible do
        association_chain
      end

      unobtrusive_method :association_chain_with_includes do
        association_chain_with_accessible
      end

      unobtrusive_method :end_of_association_chain do
        association_chain_with_includes
      end

      unobtrusive_method :unobtrusive_params do
        params
      end

      unobtrusive_method :finder_method do
        :find
      end

      unobtrusive_method :finder_param do
        :id
      end

      unobtrusive_method :resource_collection_name do
        resource_class.model_name.plural
      end

      unobtrusive_method :resource_name do
        resource_class.model_name.singular.to_sym
      end

      # TODO: remove this method.
      # Looks like this method is not used.
      unobtrusive_method :relationship_singular_name do
        resource_class.to_s.underscore.to_sym
      end

      unobtrusive_method :permitted_params do
        unobtrusive_params.permit(permitted_params_key => send("permitted_params_#{action_name}_value"))[permitted_params_key]
      end

      unobtrusive_method :build_permitted_params do
        {}
      end

      unobtrusive_method :collection_url do |*args|
        url_for(collection_route(*args))
      end

      unobtrusive_method :resource_url do |*args|
        url_for(resource_route(args))
      end

      unobtrusive_method :resource_route do |*args|
        [resource, *args]
      end

      unobtrusive_method :edit_resource_url do |*args|
        url_for(edit_resource_route(*args))
      end

      unobtrusive_method :edit_resource_route do |*args|
        [:edit, resource, *args]
      end

      unobtrusive_method :new_resource_url do |*args|
        url_for(new_resource_route(*args))
      end

      unobtrusive_method :new_resource_route do |*args|
        [:new, resource_name, *args]
      end

      # parent methods
      if method_defined?(:parent_class) || private_method_defined?(:parent_class)
        helper_method :parent, :parent_class, :parent_name, :parent_collection_name, :parent_url

        unobtrusive_method :parent do
          instance_variable_set(:@_parent, parent_class.public_send(parent_finder_method, unobtrusive_params[parent_finder_param])) unless instance_variable_defined?(:@_parent)
          instance_variable_get(:@_parent)
        end

        # TODO: Rename `unoptrusive_parent_params` => `unobtrusive_parent_params`
        # Check if this method is used in existing repositories.
        unobtrusive_method :unoptrusive_parent_params do
          params
        end

        unobtrusive_method :parent_finder_method do
          :find
        end

        unobtrusive_method :parent_finder_param do
          :id
        end

        unobtrusive_method :parent_collection_name do
          parent_class.model_name.plural
        end

        unobtrusive_method :parent_name do
          parent_class.model_name.singular
        end

        unobtrusive_method :parent_url do |*args|
          url_for(parent_route(*args))
        end

        unobtrusive_method :parent_route do |*args|
          [parent, *args]
        end

        unobtrusive_method :collection_route do |*args|
          [parent, relationship_name, *args]
        end

        unobtrusive_method :begin_of_association_chain do
          parent
        end
      else
        unobtrusive_method :begin_of_association_chain do
          OpenStruct.new(relationship_name => resource_class.all)
        end

        unobtrusive_method :collection_route do |*args|
          [relationship_name, *args]
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include(::UnobtrusiveResources) if self == ActionController::Base
end
