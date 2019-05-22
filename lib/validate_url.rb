require 'addressable/uri'
require 'active_model'
require 'active_support/i18n'
require 'public_suffix'
I18n.load_path += Dir[File.dirname(__FILE__) + "/locale/*.yml"]

module ActiveModel
  module Validations
    class URLValidator < ActiveModel::EachValidator
      def initialize(options)
        options.reverse_merge!(:schemes => %w(http https))
        options.reverse_merge!(:no_local => false)
        options.reverse_merge!(:public_suffix => false)
        options.reverse_merge!(:no_pre_query => false)

        super(options)
      end

      def validate_each(record, attribute, value)
        @errors = []
        @record = record
        @attribute = attribute

        schemes = [*options.fetch(:schemes)].map(&:to_s)
        no_local = options.fetch(:no_local)
        public_suffix = options.fetch(:public_suffix)
        no_pre_query = options.fetch(:no_pre_query)

        begin
          uri = Addressable::URI.parse(value)
          raise Addressable::URI::InvalidURIError unless uri

          add_error(options.fetch(:message, :url_host)) unless validate_host_presence(uri)
          add_error(options.fetch(:message, :url_suffix)) unless validate_suffix(uri, public_suffix)
          add_error(options.fetch(:message, :url_suffix)) unless validate_no_local(uri, no_local)
          add_error(*options.fetch(:message, [:url_scheme, :schemes => schemes.join(', ')])) unless validate_scheme_presence(uri, schemes)
          add_error(options.fetch(:message, :url_path)) unless validate_pre_query(uri, no_pre_query)

        rescue Addressable::URI::InvalidURIError
          add_error(options.fetch(:message, :url))
        end
      end

      def add_error(*message)
        return if @errors.include?(message)
        @record.errors.add(@attribute, *message)
        @errors << message
      end

      def validate_host_presence(uri)
        uri.host && uri.host.length > 0
      end

      def validate_suffix(uri, public_suffix)
        !public_suffix || (PublicSuffix.valid?(uri.host, :default_rule => nil))
      end

      def validate_no_local(uri, no_local)
        !no_local || uri.host&.include?('.')
      end

      def validate_scheme_presence(uri, schemes)
        schemes.include?(uri.scheme)
      end

      def validate_pre_query(uri, no_pre_query)
        # URLs with queries should have a '/' before the '?'.
        no_pre_query || uri.query.nil? || uri.path&.starts_with?('/')
      end

    end

    module ClassMethods
      # Validates whether the value of the specified attribute is valid url.
      #
      #   class Unicorn
      #     include ActiveModel::Validations
      #     attr_accessor :homepage, :ftpsite
      #     validates_url :homepage, :allow_blank => true
      #     validates_url :ftpsite, :schemes => ['ftp']
      #   end
      # Configuration options:
      # * <tt>:message</tt> - A custom error message (default is: "is not a valid URL").
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).
      # * <tt>:schemes</tt> - Array of URI schemes to validate against. (default is +['http', 'https']+)

      def validates_url(*attr_names)
        validates_with URLValidator, _merge_attributes(attr_names)
      end
    end
  end
end
