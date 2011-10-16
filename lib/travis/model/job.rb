require 'active_record'

class Job < ActiveRecord::Base
  autoload :Configure, 'travis/model/job/configure'
  autoload :Tagging,   'travis/model/job/tagging'
  autoload :States,    'travis/model/job/states'
  autoload :Test,      'travis/model/job/test'

  belongs_to :repository
  belongs_to :commit
  belongs_to :owner, :polymorphic => true, :autosave => true

  validates :repository_id, :commit_id, :owner_id, :owner_type, :presence => true

  serialize :config

  after_initialize do
    self.config = {} if config.nil?
  end

  def matrix_config?(config)
    config = config.to_hash.symbolize_keys
    Build.matrix_keys_for(config).map do |key|
      self.config[key.to_sym] == config[key] || commit.branch == config[key]
    end.inject(:&)
  end
end