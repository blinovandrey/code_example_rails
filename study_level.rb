# == Schema Information
#
# Table name: study_levels
#
#  id            :integer          not null, primary key
#  level_id      :integer
#  address       :string
#  start_at      :datetime
#  end_at        :datetime
#  cost          :decimal(, )
#  description   :string
#  article       :string
#  city_id       :integer
#  seats         :integer
#  nearest_event :boolean          default(TRUE)
#  allow_enroll  :boolean          default(TRUE)
#  link          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_study_levels_on_city_id   (city_id)
#  index_study_levels_on_level_id  (level_id)
#

class StudyLevel < ApplicationRecord
  belongs_to :city, class_name: Catalog::City
  has_and_belongs_to_many :speakers, class_name: 'Catalog::Speaker'
  has_many :users_levels, dependent: :destroy
  has_many :users, through: :users_levels
  has_many :study_queues
  belongs_to :level, class_name: 'Catalog::Level'

  has_many :study_level_payment_requests

  validates :start_at, :end_at, :address, :cost, :description,
            :article, presence: true

  after_commit :add_to_sidekiq, on: :create
  after_commit :start_notification_worker, on: :create

  default_scope { order(:id) }

  scope :nearest, (lambda { |level_id|
    where('start_at >= ? AND level_id = ?', Date.today, level_id)
        .reorder(:start_at)
  })

  scope :nearest_three, (lambda { |level_id|
    where('start_at >= ? AND level_id = ?', Date.today, level_id)
        .reorder(:start_at).limit(3)
  })
  scope :actual, (-> { where('start_at >= ?', Date.today).reorder(:start_at) })
  scope :by_course_and_position, (lambda { |study_course_id, position|
    joins(:level)
        .where('study_course_id = ? AND levels.position = ?', study_course_id, position)
  })

  def payment_date(user_id)
    users_level = users_levels.find_by(user_id: user_id)
    order = StudyLevelOrder.find_by(users_level_id: users_level.try(:id))
    payment_request = StudyLevelPaymentRequest.find_by(study_level_id: id, user_id: user_id)

    if order.present?
      order.try(:updated_at)
    elsif payment_request.try(:paid?)
      payment_request.try(:updated_at)
    end
  end

  def legal?(user_id)
    payment_request = StudyLevelPaymentRequest.exists?(study_level_id: id, user_id: user_id, paid: true)
  end

  def remaining_seats
    seats - users_levels.where(study_status: %i(paid payment_requested)).count if seats.present?
  end

  def add_to_sidekiq
    StudyLevelEnrollWorker.perform_at(end_at, id)
  end

  def start_notification_worker
    scheduled_start = (Catalog::StudyLevelsNotification.first.try(:scheduled_start) || 0).day
    date = start_at - scheduled_start

    StudyLevelsNotificationWorker.perform_at(date, id)
  end

  def display_name
    article || level.try(:title)
  end

  def not_allow_enroll?
    !allow_enroll?
  end
end

