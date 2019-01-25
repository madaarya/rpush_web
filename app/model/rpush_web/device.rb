module RpushWeb
  class Device < ActiveRecord::Base
    # OS:
    enum platform: {
      ios: 1,
      android: 2
    }

    # Associations:
    belongs_to :owner, polymorphic: true

    # Validations:
    # validates :owner_id, presence: true
    # validates :owner_type, presence: true
    validates :platform, presence: true
    validates :token, presence: true
    # validates :token, uniqueness: { scope: [:owner_id, :owner_type] }

    # Hooks:
    after_create :invalidate_used_token
    before_validation :set_the_platform

    private

    def set_the_platform
      if self.platform.present?
        self.platform = self.platform.eql?('ios') ? 1 : 2
      end
    end

    def invalidate_used_token
      RpushWeb::Device.where(token: token).where('id != ?', id).delete_all
    end

    class << self
      def for_owner(owner)
        where(owner_id: owner.id, owner_type: owner.class.base_class)
      end
    end
  end
end