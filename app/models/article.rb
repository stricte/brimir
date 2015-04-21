class Article < ActiveRecord::Base

  validates_presence_of :title, :description, :body
  attr_accessor :labels_list
  after_create :create_labels
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      where('LOWER(title) LIKE ? ESCAPE ? OR LOWER(description) LIKE ? ESCAPE ? OR LOWER(body) LIKE ? ESCAPE ?',
                         term, '!', term, '!', term, '!')
    end
  }

  scope :ordered, -> {
    order(:created_at).reverse_order
  }

  scope :by_label_id, ->(label_id) {
    if label_id.to_i > 0
      joins(:labelings).where(labelings: { label_id: label_id })
    end
  }

  scope :sorted, lambda { |param, direction|
    parts = param.split('.')
    direction = direction == 'asc' ? 'asc' : 'desc'

    if parts.count == 1 && Article.column_names.include?(parts.first)
      order(parts.first + ' ' + direction)
    elsif parts.count > 1
      attr = parts.pop
      assoc_hash = parts.reverse.inject({}) { |a, n| { n => a } }
      includes(assoc_hash).references(assoc_hash).order(attr + ' ' + direction)
    end
  }

  private
  def create_labels
    self.labels_list.split(',').each do |label|
      self.labelings.create({label: {name: label.strip}})
    end unless self.labels_list.blank?
  end

end
