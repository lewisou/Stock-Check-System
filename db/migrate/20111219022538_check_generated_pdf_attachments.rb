class CheckGeneratedPdfAttachments < ActiveRecord::Migration
  def self.up
    create_table :check_generated_pdf_attachments, :id => false do |t|
      t.integer :check_id
      t.integer :attachment_id
    end
    
    add_index :check_generated_pdf_attachments, :attachment_id
  end

  def self.down
    remove_index :check_generated_pdf_attachments, :attachment_id

    drop_table :check_generated_pdf_attachments
  end
end
