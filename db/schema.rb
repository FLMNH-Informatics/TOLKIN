# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130912153934) do

  create_table "advanced_searches", :force => true do |t|
    t.string   "params"
    t.string   "model"
    t.integer  "people_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alignment_outputs", :force => true do |t|
    t.integer "alignment_id"
    t.string  "alignment_type"
    t.text    "alignment_text"
  end

  create_table "alignment_seqs", :force => true do |t|
    t.integer "alignment_id"
    t.integer "seq_id"
  end

  create_table "alignments", :force => true do |t|
    t.string   "name",           :null => false
    t.text     "description"
    t.text     "seq"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timeline_id"
    t.string   "matrix_address"
  end

  create_table "annotations", :force => true do |t|
    t.integer "collection_id",                :null => false
    t.string  "taxon"
    t.string  "name"
    t.string  "date",          :limit => nil
    t.string  "inst"
  end

  create_table "authors", :force => true do |t|
    t.string  "name"
    t.integer "project_id"
    t.date    "created_at"
    t.integer "creator_id"
  end

  create_table "biodatabase", :primary_key => "biodatabase_id", :force => true do |t|
    t.string "name",        :limit => 128, :null => false
    t.string "authority",   :limit => 128
    t.text   "description"
  end

  add_index "biodatabase", ["authority"], :name => "db_auth"
  add_index "biodatabase", ["name"], :name => "biodatabase_name_key", :unique => true
  add_index "biodatabase", ["name"], :name => "biodatabase_name_key1", :unique => true

  create_table "bioentry", :primary_key => "bioentry_id", :force => true do |t|
    t.integer "biodatabase_id",                     :null => false
    t.integer "taxon_id"
    t.string  "name",                :limit => 40,  :null => false
    t.string  "accession",           :limit => 128
    t.string  "identifier",          :limit => 40
    t.string  "division",            :limit => 6
    t.text    "description"
    t.integer "version",                            :null => false
    t.integer "project_id"
    t.integer "genbank_bioentry_id"
    t.string  "uuid",                :limit => 36
    t.integer "user_id"
    t.string  "species_name"
  end

  add_index "bioentry", ["accession", "biodatabase_id", "version"], :name => "bioentry_accession_key", :unique => true
  add_index "bioentry", ["accession", "biodatabase_id"], :name => "bioentry_accession_key1", :unique => true
  add_index "bioentry", ["biodatabase_id"], :name => "bioentry_db"
  add_index "bioentry", ["identifier", "biodatabase_id"], :name => "bioentry_identifier_key", :unique => true
  add_index "bioentry", ["identifier", "biodatabase_id"], :name => "bioentry_identifier_key1", :unique => true
  add_index "bioentry", ["name"], :name => "bioentry_name"
  add_index "bioentry", ["taxon_id"], :name => "bioentry_tax"
  add_index "bioentry", ["uuid"], :name => "uc_uuid", :unique => true

  create_table "bioentry_dbxref", :id => false, :force => true do |t|
    t.integer "bioentry_id", :null => false
    t.integer "dbxref_id",   :null => false
    t.integer "rank"
  end

  add_index "bioentry_dbxref", ["dbxref_id"], :name => "dblink_dbx"

  create_table "bioentry_path", :id => false, :force => true do |t|
    t.integer "object_bioentry_id",  :null => false
    t.integer "subject_bioentry_id", :null => false
    t.integer "term_id",             :null => false
    t.integer "distance"
  end

  add_index "bioentry_path", ["object_bioentry_id", "subject_bioentry_id", "term_id", "distance"], :name => "bioentry_path_object_bioentry_id_key", :unique => true
  add_index "bioentry_path", ["subject_bioentry_id"], :name => "bioentrypath_child"
  add_index "bioentry_path", ["term_id"], :name => "bioentrypath_trm"

  create_table "bioentry_qualifier_value", :id => false, :force => true do |t|
    t.integer "bioentry_id",                :null => false
    t.integer "term_id",                    :null => false
    t.text    "value"
    t.integer "rank",        :default => 0, :null => false
  end

  add_index "bioentry_qualifier_value", ["bioentry_id", "term_id", "rank"], :name => "bioentry_qualifier_value_bioentry_id_key", :unique => true
  add_index "bioentry_qualifier_value", ["term_id"], :name => "bioentryqual_trm"

  create_table "bioentry_reference", :id => false, :force => true do |t|
    t.integer "bioentry_id",                 :null => false
    t.integer "reference_id",                :null => false
    t.integer "start_pos"
    t.integer "end_pos"
    t.integer "rank",         :default => 0, :null => false
  end

  add_index "bioentry_reference", ["reference_id"], :name => "bioentryref_ref"

  create_table "bioentry_relationship", :primary_key => "bioentry_relationship_id", :force => true do |t|
    t.integer "object_bioentry_id",  :null => false
    t.integer "subject_bioentry_id", :null => false
    t.integer "term_id",             :null => false
    t.integer "rank"
  end

  add_index "bioentry_relationship", ["object_bioentry_id", "subject_bioentry_id", "term_id"], :name => "bioentry_relationship_object_bioentry_id_key", :unique => true
  add_index "bioentry_relationship", ["subject_bioentry_id"], :name => "bioentryrel_child"
  add_index "bioentry_relationship", ["term_id"], :name => "bioentryrel_trm"

  create_table "biosequence", :id => false, :force => true do |t|
    t.integer "bioentry_id",               :null => false
    t.integer "version"
    t.integer "length"
    t.string  "alphabet",    :limit => 10
    t.text    "seq"
  end

  add_index "biosequence", ["bioentry_id"], :name => "biosequence_bioentry_id_key", :unique => true

  create_table "bookmarks", :force => true do |t|
    t.string "url", :limit => nil
  end

  create_table "branch_items", :force => true do |t|
    t.integer "item_id"
    t.string  "item_type"
    t.integer "copied_from_id"
    t.integer "project_id"
  end

  create_table "branch_items_branches", :force => true do |t|
    t.integer "branch_id"
    t.integer "branch_item_id"
    t.integer "position"
    t.integer "copied_from_id"
    t.integer "project_id"
  end

  create_table "branches", :force => true do |t|
    t.integer  "branch_number"
    t.string   "item_type"
    t.integer  "object_history_id"
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "creator_id",        :null => false
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.integer  "copied_from_id"
  end

  create_table "bulk_upload_filenames", :force => true do |t|
    t.string   "filename"
    t.datetime "date"
    t.string   "record_model"
    t.integer  "project_id"
  end

  create_table "bulk_upload_records", :force => true do |t|
    t.integer "bulk_upload_filename_id"
    t.integer "record_id"
    t.boolean "is_taxon"
  end

  create_table "bulk_uploads_custom_mappings", :force => true do |t|
    t.string   "name"
    t.text     "map"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "changeset_change_types", :force => true do |t|
    t.string "name"
  end

  create_table "changeset_items", :force => true do |t|
    t.string  "change_type"
    t.integer "changeset_id"
    t.integer "old_version_id"
    t.string  "old_version_type"
    t.integer "new_version_id"
    t.string  "new_version_type"
    t.integer "position"
    t.integer "move_to_next_position"
    t.integer "move_to_prev_position"
    t.integer "parent_id"
    t.string  "options"
  end

  create_table "changesets", :force => true do |t|
    t.integer  "committer_id",     :null => false
    t.datetime "committed_at"
    t.integer  "changeset_number"
    t.integer  "branch_id"
  end

  create_table "characters", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "short_name"
    t.integer  "project_id"
    t.integer  "creator_id",                                        :null => false
    t.integer  "updator_id",                                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pos"
    t.integer  "original_position"
    t.integer  "timeline_nid",      :limit => 8
    t.boolean  "is_working_copy",                :default => false, :null => false
    t.boolean  "is_current",                     :default => false
    t.integer  "copied_from_id"
    t.integer  "old_id"
  end

  create_table "characters_chr_groups", :force => true do |t|
    t.integer  "chr_group_id"
    t.integer  "character_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "characters_citations", :id => false, :force => true do |t|
    t.integer "character_id", :null => false
    t.integer "citation_id",  :null => false
  end

  create_table "characters_matrices", :force => true do |t|
    t.integer "character_id"
    t.integer "matrix_id"
    t.integer "position"
    t.boolean "updated"
    t.boolean "new_flag"
    t.boolean "marked_for_deletion"
  end

  add_index "characters_matrices", ["character_id", "matrix_id"], :name => "characters_matrices_character_id_key", :unique => true

  create_table "chr_groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "perspective"
    t.integer  "order_seq_no"
    t.string   "sensor"
    t.integer  "project_id"
    t.string   "chr_group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public"
    t.integer  "creator_id",     :null => false
    t.integer  "updator_id",     :null => false
  end

  create_table "chr_groups_matrices", :id => false, :force => true do |t|
    t.integer  "chr_group_id"
    t.integer  "matrix_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chr_images", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "bac_id"
    t.integer  "project_id",            :null => false
    t.integer  "width"
    t.integer  "height"
    t.string   "caption"
    t.string   "photographers_credits"
  end

  create_table "chr_states", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "character_id"
    t.string   "state"
    t.string   "polarity"
    t.integer  "creator_id",                  :null => false
    t.integer  "updator_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "citation_id",    :limit => 8
    t.integer  "copied_from_id"
    t.integer  "old_id"
  end

  create_table "chr_states_citations", :id => false, :force => true do |t|
    t.integer "chr_state_id", :null => false
    t.integer "citation_id",  :null => false
  end

  create_table "citation_files", :force => true do |t|
    t.string   "name",                         :null => false
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original_name", :limit => nil, :null => false
  end

  create_table "citation_types", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "user_id"
  end

  create_table "citations", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.string   "jl"
    t.string   "volume"
    t.string   "number"
    t.string   "issue"
    t.string   "pages"
    t.string   "edition"
    t.string   "key"
    t.string   "keywords"
    t.text     "abstract"
    t.string   "editor"
    t.string   "series_editor"
    t.string   "st"
    t.string   "series_volume"
    t.string   "isbn_or_issn"
    t.string   "url"
    t.string   "doi"
    t.string   "notes"
    t.integer  "citation_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "publication_id_old"
    t.string   "city",                    :limit => nil
    t.integer  "publisher_id"
    t.integer  "image_id"
    t.integer  "number_of_volumes"
    t.string   "chapter",                 :limit => nil
    t.string   "bt",                      :limit => nil
    t.string   "year"
    t.integer  "user_id"
    t.integer  "citations_attributes_id"
    t.integer  "updated_by"
    t.integer  "publication_id"
    t.text     "authors_fulltext"
  end

  create_table "citations_otus", :id => false, :force => true do |t|
    t.integer "otu_id"
    t.integer "citation_id"
  end

  create_table "citations_state_codings", :id => false, :force => true do |t|
    t.integer "citation_id"
    t.integer "state_coding_id"
  end

  create_table "citations_taxa", :id => false, :force => true do |t|
    t.integer "citation_id", :null => false
    t.integer "taxon_id",    :null => false
  end

# Could not dump table "collections" because of following StandardError
#   Unknown type 'direction' for column 'long_dir'

  create_table "comment", :primary_key => "comment_id", :force => true do |t|
    t.integer "bioentry_id",                 :null => false
    t.text    "comment_text",                :null => false
    t.integer "rank",         :default => 0, :null => false
  end

  add_index "comment", ["bioentry_id", "rank"], :name => "comment_bioentry_id_key", :unique => true

  create_table "contributorships", :force => true do |t|
    t.integer  "person_id"
    t.integer  "citation_id"
    t.integer  "position"
    t.integer  "pen_name_id"
    t.boolean  "highlight"
    t.integer  "score"
    t.boolean  "hide"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
  end

  create_table "countries", :force => true do |t|
    t.string "name", :limit => 100, :null => false
    t.string "iso2", :limit => 2,   :null => false
  end

  create_table "custom_mappings", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "mapping"
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dbxref", :primary_key => "dbxref_id", :force => true do |t|
    t.string  "dbname",    :limit => 40,  :null => false
    t.string  "accession", :limit => 128, :null => false
    t.integer "version",                  :null => false
  end

  add_index "dbxref", ["accession", "dbname", "version"], :name => "dbxref_accession_key", :unique => true
  add_index "dbxref", ["dbname"], :name => "dbxref_db"

  create_table "dbxref_qualifier_value", :id => false, :force => true do |t|
    t.integer "dbxref_id",                :null => false
    t.integer "term_id",                  :null => false
    t.integer "rank",      :default => 0, :null => false
    t.text    "value"
  end

  add_index "dbxref_qualifier_value", ["dbxref_id"], :name => "dbxrefqual_dbx"
  add_index "dbxref_qualifier_value", ["term_id"], :name => "dbxrefqual_trm"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dna_samples", :force => true do |t|
    t.integer "taxonomy_id_old",     :limit => 8
    t.integer "collection_id_old",   :limit => 8
    t.string  "sample_nr",           :limit => nil
    t.string  "sample_type",         :limit => nil
    t.string  "amount",              :limit => nil
    t.string  "deposited",           :limit => nil
    t.date    "date_received"
    t.date    "date_extracted"
    t.string  "extraction_protocol", :limit => nil
    t.string  "source",              :limit => nil
    t.string  "private_source",      :limit => nil
    t.string  "team",                :limit => nil
    t.string  "notes",               :limit => nil
    t.date    "created_at"
    t.integer "creator_id_old",      :limit => 8
    t.date    "updated_at"
    t.integer "updator_id_old",      :limit => 8
    t.string  "guid",                :limit => nil
    t.string  "loc_freezer",         :limit => nil
    t.string  "loc_shelf_bin",       :limit => nil
    t.string  "loc_rack_bag",        :limit => nil
    t.string  "loc_box",             :limit => nil
    t.string  "loc_column",          :limit => nil
    t.string  "loc_row",             :limit => nil
    t.integer "project_id",          :limit => 8
    t.integer "taxon_id"
    t.integer "collection_id"
    t.integer "creator_id"
    t.integer "updator_id"
    t.integer "recpermission_id",                   :default => 1
    t.integer "old_tolkin_id"
  end

  create_table "dye_compositions", :force => true do |t|
    t.string   "composition"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dyes", :force => true do |t|
    t.string   "dye_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id", :null => false
  end

  create_table "dyes_dye_compositions", :id => false, :force => true do |t|
    t.integer "dye_id"
    t.integer "dye_composition_id"
  end

  create_table "fasta_filenames", :force => true do |t|
    t.string   "filename"
    t.datetime "upload_date"
    t.integer  "project_id"
  end

  create_table "genbank_sequence_submission_records", :force => true do |t|
    t.integer "user_id"
    t.string  "genbank_id"
    t.string  "submission_title"
    t.string  "organism_name"
    t.string  "organism_location"
    t.text    "sequence"
    t.string  "sequence_title"
    t.string  "strain"
    t.date    "creation_time"
    t.date    "updation_time"
  end

  create_table "genetic_code", :force => true do |t|
    t.string "gen_code"
  end

  create_table "granted_roles", :force => true do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.integer "role_type_id"
  end

  create_table "hybridizations", :force => true do |t|
    t.integer "probe_id"
    t.integer "dye_id"
    t.integer "z_file_id"
  end

  create_table "images", :force => true do |t|
    t.integer  "parent_id"
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.string   "thumbnail"
    t.integer  "attachment_file_size"
    t.integer  "width"
    t.integer  "height"
    t.date     "date_taken"
    t.integer  "created_by"
    t.integer  "modified_by"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "attachment_updated_at"
    t.text     "caption"
    t.string   "photographers_credits"
  end

  create_table "images_joins", :force => true do |t|
    t.integer  "object_id"
    t.string   "object_type"
    t.integer  "image_id"
    t.datetime "deleted_at"
  end

  create_table "insd_alt_seq_data", :id => false, :force => true do |t|
    t.integer "pk",   :null => false
    t.string  "name"
  end

  create_table "insd_alt_seq_data_item", :id => false, :force => true do |t|
    t.integer "pk",              :null => false
    t.integer "alt_seq_data_pk"
    t.integer "interval_pk"
    t.boolean "isgap"
    t.integer "gap_length"
    t.string  "gap_type"
    t.string  "gap_linkage"
    t.string  "gap_comment"
    t.string  "first_accn"
    t.string  "last_accn"
    t.text    "value"
  end

  create_table "insd_author", :primary_key => "pk", :force => true do |t|
    t.string "value"
  end

  create_table "insd_comment", :primary_key => "pk", :force => true do |t|
    t.string "type"
  end

  create_table "insd_comment_paragraph", :primary_key => "pk", :force => true do |t|
    t.integer "comment_pk"
  end

  create_table "insd_comment_paragraph_item", :primary_key => "pk", :force => true do |t|
    t.integer "paragraph_pk"
    t.string  "value"
    t.string  "url"
  end

  create_table "insd_feature", :primary_key => "pk", :force => true do |t|
    t.string  "key"
    t.string  "location"
    t.string  "operator"
    t.boolean "partial5"
    t.boolean "partial3"
  end

  create_table "insd_feature_intervals", :id => false, :force => true do |t|
    t.integer "feature_pk",  :null => false
    t.integer "interval_pk", :null => false
  end

  create_table "insd_feature_quals", :id => false, :force => true do |t|
    t.integer "feature_pk",   :null => false
    t.integer "qualifier_pk", :null => false
  end

  create_table "insd_feature_set", :primary_key => "pk", :force => true do |t|
    t.string "annot_source"
  end

  create_table "insd_feature_set_features", :id => false, :force => true do |t|
    t.integer "feature_set_pk", :null => false
    t.integer "feature_pk",     :null => false
  end

  create_table "insd_feature_xrefs", :id => false, :force => true do |t|
    t.integer "feature_pk", :null => false
    t.integer "xref_pk",    :null => false
  end

  create_table "insd_interval", :primary_key => "pk", :force => true do |t|
    t.integer "from"
    t.integer "to"
    t.integer "point"
    t.boolean "iscomp"
    t.boolean "interbp"
    t.string  "accession"
  end

  create_table "insd_qualifier", :primary_key => "pk", :force => true do |t|
    t.string "name"
    t.text   "value"
  end

  create_table "insd_reference", :primary_key => "pk", :force => true do |t|
    t.string  "reference"
    t.string  "position"
    t.string  "consortium"
    t.string  "title"
    t.string  "journal"
    t.integer "xref_pk"
    t.integer "pubmed"
    t.string  "remark"
  end

  create_table "insd_reference_authors", :id => false, :force => true do |t|
    t.integer "reference_pk", :null => false
    t.integer "author_pk",    :null => false
  end

  create_table "insd_seq", :primary_key => "pk", :force => true do |t|
    t.string   "locus"
    t.integer  "length"
    t.string   "strandedness"
    t.string   "moltype"
    t.string   "topology"
    t.string   "division"
    t.date     "update_date"
    t.date     "create_date"
    t.date     "update_release"
    t.date     "create_release"
    t.string   "definition"
    t.string   "primary_accession"
    t.string   "entry_version"
    t.string   "accession_version"
    t.string   "project"
    t.string   "segment"
    t.string   "source"
    t.string   "organism"
    t.string   "taxonomy"
    t.text     "comment"
    t.text     "primary"
    t.string   "source_db"
    t.string   "database_reference"
    t.integer  "feature_set_pk"
    t.text     "sequence"
    t.text     "contig"
    t.integer  "alt_seq_pk"
    t.integer  "project_id",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "taxon_id"
    t.text     "gb_metadata"
    t.text     "markers_fulltext"
    t.integer  "fasta_filename_id"
    t.integer  "old_dna_id"
  end

  create_table "insd_seq_comment_set", :id => false, :force => true do |t|
    t.integer "seq_pk",     :null => false
    t.integer "comment_pk", :null => false
  end

  create_table "insd_seq_feature_table", :id => false, :force => true do |t|
    t.integer "seq_pk",     :null => false
    t.integer "feature_pk", :null => false
  end

  create_table "insd_seq_keyword", :primary_key => "pk", :force => true do |t|
    t.integer "insd_seq_pk"
    t.string  "value"
  end

  create_table "insd_seq_markers", :force => true do |t|
    t.integer "seq_id"
    t.integer "marker_id"
    t.string  "position"
    t.integer "start_position"
    t.integer "end_position"
  end

  create_table "insd_seq_other_seqid", :primary_key => "pk", :force => true do |t|
    t.integer "insd_seq_pk"
    t.string  "seqid"
  end

  create_table "insd_seq_references", :id => false, :force => true do |t|
    t.integer "seq_pk",       :null => false
    t.integer "reference_pk", :null => false
  end

  create_table "insd_seq_secondary_accn", :primary_key => "pk", :force => true do |t|
    t.integer "insd_seq_pk"
    t.string  "value"
  end

  create_table "insd_seq_struc_comments", :id => false, :force => true do |t|
    t.integer "seq_pk",           :null => false
    t.integer "struc_comment_pk", :null => false
  end

  create_table "insd_struc_comment", :primary_key => "pk", :force => true do |t|
    t.string "name"
  end

  create_table "insd_struc_comment_item", :primary_key => "pk", :force => true do |t|
    t.integer "struc_comment_pk"
    t.string  "tag"
    t.string  "value"
    t.string  "url"
  end

  create_table "insd_xref", :primary_key => "pk", :force => true do |t|
    t.string "dbname"
    t.string "id"
  end

  create_table "ip_logs", :force => true do |t|
    t.integer  "failed_logins"
    t.datetime "last_login"
    t.string   "ip_addr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", :force => true do |t|
    t.string   "description"
    t.string   "subject"
    t.string   "external_status_code"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

# Could not dump table "l_publications" because of following StandardError
#   Unknown type 'publication_type' for column 'publication_type'

  create_table "lengthunits", :id => false, :force => true do |t|
    t.integer "id",                                  :null => false
    t.string  "name",                 :limit => nil, :null => false
    t.float   "conversion_to_meters"
  end

  create_table "location", :primary_key => "location_id", :force => true do |t|
    t.integer "seqfeature_id",                      :null => false
    t.integer "dbxref_id"
    t.integer "term_id"
    t.integer "start_pos"
    t.integer "end_pos"
    t.integer "strand",              :default => 0, :null => false
    t.integer "rank",                :default => 0, :null => false
    t.integer "genbank_location_id"
  end

  add_index "location", ["dbxref_id"], :name => "seqfeatureloc_dbx"
  add_index "location", ["seqfeature_id", "rank"], :name => "location_seqfeature_id_key", :unique => true
  add_index "location", ["start_pos", "end_pos"], :name => "seqfeatureloc_start"
  add_index "location", ["term_id"], :name => "seqfeatureloc_trm"

  create_table "location_qualifier_value", :id => false, :force => true do |t|
    t.integer "location_id", :null => false
    t.integer "term_id",     :null => false
    t.string  "value",       :null => false
    t.integer "int_value"
  end

  add_index "location_qualifier_value", ["term_id"], :name => "locationqual_trm"

  create_table "marked_records", :force => true do |t|
    t.string   "type",       :limit => nil, :null => false
    t.integer  "type_id",                   :null => false
    t.datetime "created_at",                :null => false
    t.integer  "user_id",                   :null => false
  end

  create_table "matrices", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.integer  "updator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",      :limit => 8
    t.boolean  "backup"
    t.integer  "copied_from_id"
  end

  create_table "matrices_otu_groups", :force => true do |t|
    t.integer  "matrix_checkpoint_id"
    t.integer  "otu_group_id"
    t.string   "color",                :limit => 10
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updater_id"
  end

  create_table "matrices_otus", :force => true do |t|
    t.integer "otu_id"
    t.integer "matrix_id"
    t.integer "position"
    t.boolean "new_flag"
    t.boolean "marked_for_deletion"
  end

  add_index "matrices_otus", ["matrix_id", "otu_id"], :name => "matrices_otus_matrix_id_key", :unique => true

  create_table "mol_markers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "creator_id",  :null => false
    t.datetime "created_at"
    t.integer  "project_id"
    t.string   "lower_name"
    t.string   "type"
  end

  create_table "mol_matrices_markers", :force => true do |t|
    t.integer  "marker_id"
    t.integer  "timeline_id"
    t.datetime "create_date"
    t.datetime "delete_date"
    t.integer  "position"
  end

  create_table "mol_matrices_otus", :force => true do |t|
    t.integer  "otu_id"
    t.integer  "timeline_id"
    t.datetime "create_date"
    t.datetime "delete_date"
    t.integer  "position"
  end

  create_table "mol_matrix_cell_sequences", :id => false, :force => true do |t|
    t.integer "cell_id"
    t.integer "seq_id"
  end

  create_table "mol_matrix_cells", :force => true do |t|
    t.integer  "marker_id",                 :null => false
    t.integer  "otu_id",                    :null => false
    t.integer  "creator_id",                :null => false
    t.integer  "responsible_user_id"
    t.integer  "primary_sequence_id"
    t.integer  "status_id"
    t.string   "notes"
    t.integer  "timeline_id"
    t.integer  "sequence_count"
    t.string   "primary_sequence_locus"
    t.string   "responsible_user_initials"
    t.string   "status_text"
    t.datetime "create_date"
    t.datetime "overwrite_date"
    t.boolean  "is_active"
  end

  create_table "mol_matrix_checkpoints", :force => true do |t|
    t.integer "project_id"
  end

  create_table "mol_matrix_statuses", :force => true do |t|
    t.string  "name"
    t.integer "position"
    t.integer "project_id"
  end

  create_table "molecular_matrices", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.integer  "copied_from_id"
  end

  create_table "molecular_matrices_otu_groups", :force => true do |t|
    t.integer  "matrix_checkpoint_id"
    t.integer  "otu_group_id"
    t.string   "color",                :limit => 10
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updater_id"
    t.integer  "timeline_id"
  end

  create_table "molecular_matrix_cells", :force => true do |t|
    t.integer  "marker_id"
    t.integer  "otu_id"
    t.integer  "timeline_id"
    t.integer  "created_by"
    t.datetime "create_date"
    t.datetime "overwrite_date"
    t.integer  "responsible_user_id"
    t.integer  "primary_sequence_id"
    t.integer  "status_id"
    t.text     "notes"
    t.integer  "sequece_count"
    t.string   "primary_sequence_locus"
    t.string   "responsible_user_initials"
    t.string   "status_text"
    t.boolean  "is_active"
  end

  create_table "molecular_matrix_molecular_matrices_otu_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "molecular_matrix_submatrices", :force => true do |t|
    t.integer "timeline_id"
    t.string  "name"
  end

  create_table "molecular_matrix_submatrix_markers", :force => true do |t|
    t.integer "submatrix_id"
    t.integer "marker_id"
    t.integer "position"
  end

  create_table "molecular_matrix_submatrix_otus", :force => true do |t|
    t.integer "submatrix_id"
    t.integer "otu_id"
    t.integer "position"
  end

  create_table "molecular_matrix_timelines", :force => true do |t|
    t.integer  "matrix_id"
    t.text     "description"
    t.integer  "updater_id"
    t.datetime "updated_at"
    t.datetime "delete_date"
    t.boolean  "editable",    :default => true
  end

  create_table "morphology_matrices", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.integer  "copied_from_id"
  end

  create_table "morphology_matrices_characters", :force => true do |t|
    t.integer  "timeline_id"
    t.integer  "character_id"
    t.integer  "position"
    t.datetime "create_date"
    t.datetime "delete_date"
  end

  create_table "morphology_matrices_otus", :force => true do |t|
    t.integer  "timeline_id"
    t.integer  "otu_id"
    t.integer  "position"
    t.datetime "create_date"
    t.datetime "delete_date"
  end

  create_table "morphology_matrix_cell_citations", :id => false, :force => true do |t|
    t.integer "cell_id"
    t.integer "citation_id"
  end

  create_table "morphology_matrix_cells", :force => true do |t|
    t.integer  "timeline_id"
    t.integer  "character_id"
    t.integer  "otu_id"
    t.text     "status"
    t.text     "state_codings"
    t.text     "notes"
    t.datetime "create_date"
    t.datetime "overwrite_date"
    t.boolean  "is_active"
    t.integer  "creator_id"
  end

  create_table "morphology_matrix_matrices_otu_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "morphology_matrix_submatrices", :force => true do |t|
    t.integer "timeline_id"
    t.integer "matrix_id"
    t.string  "name"
  end

  create_table "morphology_matrix_submatrix_characters", :force => true do |t|
    t.integer "submatrix_id"
    t.integer "character_id"
    t.integer "position"
  end

  create_table "morphology_matrix_submatrix_otus", :force => true do |t|
    t.integer "submatrix_id"
    t.integer "otu_id"
    t.integer "position"
  end

  create_table "morphology_matrix_timelines", :force => true do |t|
    t.integer  "matrix_id"
    t.text     "description"
    t.integer  "updater_id"
    t.datetime "updated_at"
    t.datetime "delete_date"
    t.integer  "version"
    t.boolean  "editable",    :default => true
  end

  create_table "name_strings", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "namestatuses", :force => true do |t|
    t.string "status",      :null => false
    t.string "description"
  end

  create_table "nexus_datasets", :force => true do |t|
    t.string   "filename",     :limit => nil
    t.integer  "project_id",   :limit => 8
    t.integer  "creator_id",   :limit => 8
    t.integer  "updator_id",   :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type", :limit => nil
    t.integer  "parent_id"
    t.integer  "size"
  end

  create_table "nodes", :primary_key => "nid", :force => true do |t|
  end

  create_table "object_histories", :force => true do |t|
    t.string  "item_type"
    t.integer "copied_from_id"
  end

  create_table "ontology", :primary_key => "ontology_id", :force => true do |t|
    t.string "name",       :limit => 32, :null => false
    t.text   "definition"
  end

  add_index "ontology", ["name"], :name => "ontology_name_key", :unique => true

  create_table "ontology_compositions", :force => true do |t|
    t.integer "genus_id", :null => false
  end

  create_table "ontology_terms", :force => true do |t|
    t.string "uri"
    t.string "label"
    t.string "bioportal_ontology_identifier"
  end

  create_table "organism_location", :force => true do |t|
    t.string "location"
  end

  create_table "otu_groups", :force => true do |t|
    t.string   "name"
    t.integer  "creator_id", :null => false
    t.integer  "updator_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id", :null => false
  end

  create_table "otu_groups_otus", :force => true do |t|
    t.integer  "otu_id"
    t.integer  "otu_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "otus", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "project_id"
    t.integer  "creator_id",                                        :null => false
    t.integer  "updator_id",                                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_position"
    t.integer  "timeline_nid",      :limit => 8
    t.boolean  "is_working_copy",                :default => false, :null => false
    t.boolean  "is_current",                     :default => false
    t.integer  "copied_from_id"
    t.text     "creator_name"
  end

  create_table "otus_taxa", :id => false, :force => true do |t|
    t.integer "otu_id",   :null => false
    t.integer "taxon_id", :null => false
  end

  create_table "pen_names", :force => true do |t|
    t.integer  "name_string_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.integer  "exaternal_id"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "image_url"
    t.string   "phone"
    t.string   "im"
    t.string   "office_address_line_one"
    t.string   "office_address_line_two"
    t.string   "office_city"
    t.string   "office_state"
    t.string   "office_zip"
    t.string   "research_focus"
    t.boolean  "active"
    t.string   "scoring_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "initials"
    t.string   "country"
    t.integer  "fax"
    t.string   "institution"
    t.string   "email"
  end

  create_table "permission_set_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string "label", :null => false
  end

  add_index "permission_set_vtattrs", ["vtid"], :name => "permission_set_vcattrs_vtid_key", :unique => true

  create_table "permission_sets", :primary_key => "permission_set_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8, :null => false
    t.integer  "vtid",                      :limit => 8, :null => false
    t.integer  "owner_user_rtid",           :limit => 8, :null => false
    t.integer  "owner_record_rtid",         :limit => 8, :null => false
    t.integer  "owner_graph_rtid",          :limit => 8, :null => false
    t.integer  "owner_permission_set_rtid",              :null => false
    t.integer  "creator_rtid",              :limit => 8, :null => false
    t.datetime "created_at",                             :null => false
    t.integer  "updater_rtid",              :limit => 8, :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "label"
  end

  add_index "permission_sets", ["rtid"], :name => "permission_sets_rtid_key", :unique => true

  create_table "permission_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.integer "role_rtid",           :limit => 8, :null => false
    t.integer "permission_set_rtid", :limit => 8, :null => false
    t.boolean "visible",                          :null => false
    t.boolean "editable",                         :null => false
    t.boolean "deletable",                        :null => false
    t.boolean "permissible",                      :null => false
    t.boolean "creatable"
  end

  create_table "permissions", :primary_key => "rtid", :force => true do |t|
    t.integer  "permission_id",                          :null => false
    t.integer  "role_rtid",                 :limit => 8, :null => false
    t.integer  "permission_set_rtid",       :limit => 8, :null => false
    t.integer  "vtid",                      :limit => 8, :null => false
    t.integer  "owner_user_rtid",           :limit => 8, :null => false
    t.integer  "owner_record_rtid",         :limit => 8, :null => false
    t.integer  "owner_graph_rtid",          :limit => 8, :null => false
    t.integer  "owner_permission_set_rtid",              :null => false
    t.integer  "creator_rtid",              :limit => 8, :null => false
    t.datetime "created_at",                             :null => false
    t.integer  "updater_rtid",              :limit => 8, :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "visible",                                :null => false
    t.boolean  "editable",                               :null => false
    t.boolean  "deletable",                              :null => false
    t.boolean  "permissible",                            :null => false
    t.boolean  "creatable"
  end

  add_index "permissions", ["rtid"], :name => "permissions_rtid_key", :unique => true

  create_table "phenotypes", :force => true do |t|
    t.string  "type"
    t.integer "entity_id"
    t.string  "entity_type"
    t.integer "within_entity_id"
    t.string  "within_entity_type"
    t.boolean "is_present"
    t.integer "minimum"
    t.integer "maximum"
    t.integer "quality_id"
    t.string  "quality_type"
    t.integer "dependent_entity_id"
    t.string  "dependent_entity_type"
  end

  create_table "predicates", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  create_table "primer_genes", :force => true do |t|
    t.string  "name"
    t.integer "project_id"
  end

  create_table "primer_purification_methods", :force => true do |t|
    t.string  "name"
    t.integer "project_id"
  end

  create_table "primer_target_organisms", :force => true do |t|
    t.string  "name"
    t.integer "project_id"
  end

  create_table "primers", :force => true do |t|
    t.string   "name"
    t.text     "sequence"
    t.float    "molecular_weight"
    t.string   "tm"
    t.string   "pmol"
    t.float    "e260"
    t.boolean  "in_stock"
    t.text     "notes"
    t.integer  "project_id"
    t.datetime "created_at"
    t.integer  "creator_id"
    t.datetime "updated_at"
    t.integer  "updater_id"
    t.string   "storage_box"
    t.integer  "storage_row"
    t.integer  "storage_col"
    t.integer  "taxon_rtid",             :limit => 8
    t.integer  "marker_id",              :limit => 8
    t.integer  "purification_method_id", :limit => 8
  end

  create_table "probes", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "probe_type"
    t.text     "sequence_desc"
    t.string   "southern_signal"
    t.string   "fish_signal"
    t.string   "centromere_repeat"
    t.string   "scaffold_id"
    t.string   "scaffold_length"
    t.string   "bes_start"
    t.string   "bes_end"
    t.string   "chromosome"
    t.string   "genome_builder_super_scaffold"
  end

  create_table "probes_seqs", :id => false, :force => true do |t|
    t.integer "probe_id"
    t.integer "seq_id"
  end

  create_table "project_default_permission_sets", :id => false, :force => true do |t|
    t.integer "project_rtid",        :limit => 8, :null => false
    t.integer "permission_set_rtid", :limit => 8, :null => false
  end

  create_table "project_user_requests", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "updator_id"
  end

  create_table "project_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string  "label",                :null => false
    t.string  "logo"
    t.string  "website"
    t.integer "old_nid", :limit => 8
    t.integer "old_id"
  end

  add_index "project_vtattrs", ["vtid"], :name => "project_vcattrs_vtid_key", :unique => true

  create_table "projects", :primary_key => "project_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8,                :null => false
    t.integer  "vtid",                      :limit => 8,                :null => false
    t.integer  "owner_user_rtid",           :limit => 8,                :null => false
    t.integer  "owner_record_rtid",         :limit => 8,                :null => false
    t.integer  "owner_graph_rtid",          :limit => 8,                :null => false
    t.integer  "owner_permission_set_rtid",                             :null => false
    t.integer  "creator_rtid",              :limit => 8,                :null => false
    t.datetime "created_at",                                            :null => false
    t.integer  "updater_rtid",              :limit => 8,                :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "label",                                                 :null => false
    t.string   "logo"
    t.string   "website"
    t.integer  "old_nid",                   :limit => 8
    t.integer  "old_id"
    t.integer  "public_license_id",                      :default => 1
    t.boolean  "public"
  end

  add_index "projects", ["rtid"], :name => "projects_rtid_key", :unique => true

  create_table "properties", :primary_key => "property_id", :force => true do |t|
    t.integer "rtid", :limit => 8, :null => false
  end

  add_index "properties", ["rtid"], :name => "properties_rtid_key", :unique => true

  create_table "property_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string "label", :null => false
  end

  add_index "property_vtattrs", ["vtid"], :name => "property_vcattrs_vtid_key", :unique => true

  create_table "protologue_files", :force => true do |t|
    t.string  "object_type"
    t.string  "protologue_content_type"
    t.integer "protologue_file_size"
    t.date    "protologue_updated_at"
    t.string  "protologue_file_name"
    t.integer "taxon_id"
    t.date    "created_at"
    t.integer "creator"
  end

  create_table "public_licenses", :force => true do |t|
    t.integer  "project_id"
    t.string   "name",        :null => false
    t.string   "label"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "public_records", :force => true do |t|
    t.string  "record_model"
    t.integer "record_id"
    t.integer "project_id"
  end

  create_table "publications", :force => true do |t|
    t.integer  "publisher_id"
    t.string   "name"
    t.string   "url"
    t.string   "code"
    t.string   "issn_isbn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "citations_attributes_id"
    t.integer  "user_id"
    t.integer  "updator_id",              :null => false
  end

  create_table "publisher_sources", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.integer  "sherpa_id"
    t.integer  "source_id"
    t.integer  "authority_id"
    t.boolean  "publisher_copy"
    t.string   "url"
    t.string   "romeo_color"
    t.string   "copyright_notice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "last_updated_by"
  end

  create_table "record_type_vtattrs", :id => false, :force => true do |t|
    t.integer "vtid",  :limit => 8, :null => false
    t.string  "label",              :null => false
  end

  create_table "record_types", :primary_key => "record_type_id", :force => true do |t|
    t.integer "rtid", :null => false
  end

  add_index "record_types", ["rtid"], :name => "record_types_rtid_key", :unique => true

  create_table "recpermissions", :id => false, :force => true do |t|
    t.integer "id",                  :null => false
    t.string  "name", :limit => nil
  end

  create_table "reference", :primary_key => "reference_id", :force => true do |t|
    t.integer "dbxref_id"
    t.text    "location",                :null => false
    t.text    "title"
    t.text    "authors"
    t.string  "crc",       :limit => 32
  end

  add_index "reference", ["crc"], :name => "reference_crc_key", :unique => true
  add_index "reference", ["dbxref_id"], :name => "reference_dbxref_id_key", :unique => true

  create_table "role_member_users", :primary_key => "statement_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8, :null => false
    t.integer  "vtid",                      :limit => 8, :null => false
    t.integer  "owner_user_rtid",           :limit => 8
    t.integer  "owner_record_rtid",         :limit => 8
    t.integer  "owner_graph_rtid",          :limit => 8
    t.integer  "owner_permission_set_rtid"
    t.integer  "creator_rtid",              :limit => 8
    t.datetime "created_at"
    t.integer  "updater_rtid",              :limit => 8
    t.datetime "updated_at"
    t.integer  "subj_rtid",                 :limit => 8, :null => false
    t.integer  "prop_rtid",                 :limit => 8, :null => false
    t.integer  "obj_rtid",                  :limit => 8, :null => false
  end

  add_index "role_member_users", ["rtid"], :name => "role_member_users_rtid_key", :unique => true
  add_index "role_member_users", ["vtid"], :name => "role_member_users_vtid_key", :unique => true

  create_table "role_types", :force => true do |t|
    t.integer "rank"
    t.string  "name"
  end

  create_table "role_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string "label", :null => false
  end

  add_index "role_vtattrs", ["vtid"], :name => "role_vcattrs_vtid_key", :unique => true

  create_table "roles", :primary_key => "role_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8, :null => false
    t.integer  "vtid",                      :limit => 8, :null => false
    t.integer  "owner_user_rtid",           :limit => 8, :null => false
    t.integer  "owner_record_rtid",         :limit => 8, :null => false
    t.integer  "owner_graph_rtid",          :limit => 8, :null => false
    t.integer  "owner_permission_set_rtid",              :null => false
    t.integer  "creator_rtid",              :limit => 8, :null => false
    t.datetime "created_at",                             :null => false
    t.integer  "updater_rtid",              :limit => 8, :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "label",                                  :null => false
  end

  add_index "roles", ["rtid"], :name => "roles_rtid_key", :unique => true

  create_table "rsattrs", :primary_key => "rtid", :force => true do |t|
    t.integer  "type_rtid",                 :limit => 8, :null => false
    t.integer  "owner_user_rtid",           :limit => 8, :null => false
    t.integer  "owner_record_rtid",         :limit => 8, :null => false
    t.integer  "owner_graph_rtid",          :limit => 8, :null => false
    t.integer  "owner_permission_set_rtid",              :null => false
    t.integer  "creator_rtid",              :limit => 8, :null => false
    t.integer  "deleter_rtid",              :limit => 8
    t.datetime "created_at",                             :null => false
    t.datetime "deleted_at"
    t.integer  "type_series_id",            :limit => 8
  end

  create_table "schema_info", :id => false, :force => true do |t|
    t.integer "version"
  end

  create_table "seqfeature", :primary_key => "seqfeature_id", :force => true do |t|
    t.integer "bioentry_id",                                        :null => false
    t.integer "type_term_id",                                       :null => false
    t.integer "source_term_id",                                     :null => false
    t.string  "display_name",          :limit => 64
    t.integer "rank",                                :default => 0, :null => false
    t.integer "genbank_seqfeature_id"
  end

  add_index "seqfeature", ["bioentry_id", "type_term_id", "source_term_id", "rank"], :name => "seqfeature_bioentry_id_key", :unique => true
  add_index "seqfeature", ["source_term_id"], :name => "seqfeature_fsrc"
  add_index "seqfeature", ["type_term_id"], :name => "seqfeature_trm"

  create_table "seqfeature_dbxref", :id => false, :force => true do |t|
    t.integer "seqfeature_id", :null => false
    t.integer "dbxref_id",     :null => false
    t.integer "rank"
  end

  add_index "seqfeature_dbxref", ["dbxref_id"], :name => "feadblink_dbx"

  create_table "seqfeature_path", :id => false, :force => true do |t|
    t.integer "object_seqfeature_id",  :null => false
    t.integer "subject_seqfeature_id", :null => false
    t.integer "term_id",               :null => false
    t.integer "distance"
  end

  add_index "seqfeature_path", ["object_seqfeature_id", "subject_seqfeature_id", "term_id", "distance"], :name => "seqfeature_path_object_seqfeature_id_key", :unique => true
  add_index "seqfeature_path", ["subject_seqfeature_id"], :name => "seqfeaturepath_child"
  add_index "seqfeature_path", ["term_id"], :name => "seqfeaturepath_trm"

  create_table "seqfeature_qualifier_value", :id => false, :force => true do |t|
    t.integer "seqfeature_id",                :null => false
    t.integer "term_id",                      :null => false
    t.integer "rank",          :default => 0, :null => false
    t.text    "value",                        :null => false
  end

  add_index "seqfeature_qualifier_value", ["term_id"], :name => "seqfeaturequal_trm"

  create_table "seqfeature_relationship", :primary_key => "seqfeature_relationship_id", :force => true do |t|
    t.integer "object_seqfeature_id",  :null => false
    t.integer "subject_seqfeature_id", :null => false
    t.integer "term_id",               :null => false
    t.integer "rank"
  end

  add_index "seqfeature_relationship", ["object_seqfeature_id", "subject_seqfeature_id", "term_id"], :name => "seqfeature_relationship_object_seqfeature_id_key", :unique => true
  add_index "seqfeature_relationship", ["subject_seqfeature_id"], :name => "seqfeaturerel_child"
  add_index "seqfeature_relationship", ["term_id"], :name => "seqfeaturerel_trm"

  create_table "sequence_contigs", :force => true do |t|
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",  :null => false
    t.integer  "insd_seq_pk"
  end

  create_table "sequence_features", :force => true do |t|
    t.integer "seq_id"
    t.string  "feature"
    t.string  "qual"
    t.string  "value"
    t.string  "start_loc"
    t.string  "end_loc"
  end

  create_table "sequences", :force => true do |t|
    t.integer "dna_sample_id",         :limit => 8
    t.string  "genbank_id",            :limit => nil
    t.string  "sequence",              :limit => nil
    t.string  "completion_status",     :limit => nil
    t.string  "sub_taxon",             :limit => nil
    t.string  "notes",                 :limit => nil
    t.date    "created_at",                           :null => false
    t.integer "creator_id",            :limit => 8,   :null => false
    t.date    "updated_at",                           :null => false
    t.integer "updator_id",            :limit => 8,   :null => false
    t.string  "guid",                  :limit => nil, :null => false
    t.string  "align_method",          :limit => nil
    t.string  "responsible_user",      :limit => nil
    t.integer "project_id",            :limit => 8
    t.integer "taxonomy_id",           :limit => 8,   :null => false
    t.integer "molecular_matrices_id", :limit => 8
    t.integer "marker_id",             :limit => 8
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "state_codings", :force => true do |t|
    t.integer  "character_id",                  :null => false
    t.integer  "matrix_id"
    t.integer  "otu_id",                        :null => false
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "codings",        :limit => nil
    t.boolean  "updated_flag"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.integer  "project_id",                    :null => false
    t.integer  "copied_from_id"
  end

  create_table "statement_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.integer "subj_rtid", :limit => 8, :null => false
    t.integer "prop_rtid", :limit => 8, :null => false
    t.integer "obj_rtid",  :limit => 8, :null => false
  end

  create_table "statements_old", :id => false, :force => true do |t|
    t.integer "subj_nid", :limit => 8, :null => false
    t.integer "prop_nid", :limit => 8, :null => false
    t.integer "obj_nid",  :limit => 8, :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.integer  "user_id",       :null => false
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.integer  "creator_id"
  end

  create_table "taxa", :primary_key => "taxon_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8,                      :null => false
    t.integer  "vtid",                      :limit => 8,                      :null => false
    t.integer  "owner_user_rtid",           :limit => 8,                      :null => false
    t.integer  "owner_record_rtid",         :limit => 8,                      :null => false
    t.integer  "owner_graph_rtid",          :limit => 8,                      :null => false
    t.integer  "owner_permission_set_rtid",                                   :null => false
    t.integer  "creator_rtid",              :limit => 8,                      :null => false
    t.datetime "created_at",                                                  :null => false
    t.integer  "updater_rtid",              :limit => 8,                      :null => false
    t.datetime "updated_at",                                                  :null => false
    t.string   "name"
    t.string   "author"
    t.string   "year"
    t.integer  "accepted_name_id"
    t.integer  "namestatus_id"
    t.string   "commonname"
    t.string   "type_species"
    t.string   "type_collection",           :limit => nil
    t.string   "type_locality"
    t.text     "general_distribution"
    t.string   "notes",                     :limit => nil
    t.string   "publication"
    t.string   "volume_num"
    t.string   "pages"
    t.string   "infra_name"
    t.string   "infra_author"
    t.string   "custom_tag",                :limit => nil
    t.string   "type_herbaria",             :limit => nil
    t.string   "neotype",                   :limit => nil
    t.string   "sub_genus",                 :limit => nil
    t.string   "section",                   :limit => nil
    t.string   "major_group",               :limit => nil
    t.string   "subclade",                  :limit => nil
    t.string   "publication_date",          :limit => nil
    t.string   "ingroup_clade",             :limit => nil
    t.integer  "parent_taxon_id"
    t.integer  "old_tolkin_id"
    t.string   "old_accepted_name"
    t.string   "temp_family"
    t.string   "temp_genus"
    t.string   "temp_species"
    t.string   "chromosome_number"
    t.text     "phylogenic_relationship"
    t.text     "uses"
    t.text     "toxicity"
    t.boolean  "has_children",                             :default => false, :null => false
    t.datetime "deleted_at"
    t.text     "description"
    t.text     "conservation_status"
    t.text     "editors"
    t.string   "basionym"
    t.text     "comments"
    t.text     "habitat"
    t.integer  "ubio_id"
    t.integer  "ncbi_id"
    t.string   "treebase_id"
    t.integer  "copied_from_id"
    t.string   "subsection",                :limit => nil
    t.string   "type_date"
    t.integer  "gbif_id"
    t.integer  "eol_id"
  end

  add_index "taxa", ["rtid"], :name => "taxa_rtid_key", :unique => true

  create_table "taxon", :primary_key => "taxon_id", :force => true do |t|
    t.integer "ncbi_taxon_id"
    t.integer "parent_taxon_id"
    t.string  "node_rank",         :limit => 32
    t.integer "genetic_code",      :limit => 2
    t.integer "mito_genetic_code", :limit => 2
    t.integer "left_value"
    t.integer "right_value"
  end

  add_index "taxon", ["left_value"], :name => "xaktaxon_left_value", :unique => true
  add_index "taxon", ["ncbi_taxon_id"], :name => "xaktaxon_ncbi_taxon_id", :unique => true
  add_index "taxon", ["parent_taxon_id"], :name => "taxparent"
  add_index "taxon", ["right_value"], :name => "xaktaxon_right_value", :unique => true

  create_table "taxon_files", :force => true do |t|
    t.string  "object_type"
    t.string  "content_type"
    t.integer "size"
    t.string  "filename"
    t.date    "created_at"
    t.date    "updated_at"
    t.integer "created_by"
    t.integer "updated_by"
    t.integer "taxon_id"
  end

  create_table "taxon_name", :id => false, :force => true do |t|
    t.integer "taxon_id",                 :null => false
    t.string  "name",                     :null => false
    t.string  "name_class", :limit => 32, :null => false
  end

  add_index "taxon_name", ["name", "name_class", "taxon_id"], :name => "taxon_name_name_key", :unique => true
  add_index "taxon_name", ["name"], :name => "taxnamename"
  add_index "taxon_name", ["taxon_id"], :name => "taxnametaxonid"

  create_table "taxon_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string   "name",                                                      :null => false
    t.string   "author"
    t.string   "year"
    t.integer  "accepted_name_id"
    t.integer  "namestatus_id"
    t.string   "commonname"
    t.string   "type_species"
    t.string   "type_collection",         :limit => nil
    t.string   "type_locality"
    t.text     "general_distribution"
    t.string   "notes",                   :limit => nil
    t.string   "publication"
    t.string   "volume_num"
    t.string   "pages"
    t.string   "infra_name"
    t.string   "infra_author"
    t.string   "custom_tag",              :limit => nil
    t.string   "type_herbaria",           :limit => nil
    t.string   "neotype",                 :limit => nil
    t.string   "sub_genus",               :limit => nil
    t.string   "section",                 :limit => nil
    t.string   "major_group",             :limit => nil
    t.string   "subclade",                :limit => nil
    t.string   "publication_date",        :limit => nil
    t.string   "ingroup_clade",           :limit => nil
    t.integer  "parent_taxon_id"
    t.integer  "old_tolkin_id"
    t.string   "old_accepted_name"
    t.string   "temp_family"
    t.string   "temp_genus"
    t.string   "temp_species"
    t.string   "chromosome_number"
    t.string   "phylogenic_relationship"
    t.string   "uses"
    t.text     "toxicity"
    t.boolean  "has_children",                           :default => false, :null => false
    t.datetime "deleted_at"
    t.text     "description"
    t.string   "conservation_status"
    t.text     "editors"
    t.string   "basionym"
    t.text     "comments"
    t.text     "habitat"
    t.integer  "ubio_id"
    t.integer  "ncbi_id"
    t.string   "treebase_id"
    t.integer  "copied_from_id"
    t.string   "subsection",              :limit => nil
  end

  create_table "taxonomies", :force => true do |t|
    t.string   "name",                                                      :null => false
    t.string   "author"
    t.string   "year"
    t.integer  "accepted_name_id"
    t.integer  "namestatus_id"
    t.string   "commonname"
    t.string   "type_species"
    t.string   "type_collection",         :limit => nil
    t.string   "type_locality"
    t.text     "general_distribution"
    t.string   "notes",                   :limit => nil
    t.string   "publication"
    t.integer  "recpermission_id"
    t.integer  "project_id",                                                :null => false
    t.string   "volume_num"
    t.string   "pages"
    t.string   "infra_name"
    t.string   "infra_author"
    t.integer  "updater_id",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "custom_tag",              :limit => nil
    t.integer  "creator_id",                                                :null => false
    t.datetime "created_at"
    t.string   "type_herbaria",           :limit => nil
    t.string   "neotype",                 :limit => nil
    t.string   "sub_genus",               :limit => nil
    t.string   "section",                 :limit => nil
    t.string   "major_group",             :limit => nil
    t.string   "subclade",                :limit => nil
    t.string   "publication_date",        :limit => nil
    t.string   "ingroup_clade",           :limit => nil
    t.integer  "parent_taxon_id"
    t.integer  "old_tolkin_id"
    t.string   "old_accepted_name"
    t.string   "temp_family"
    t.string   "temp_genus"
    t.string   "temp_species"
    t.string   "chromosome_number"
    t.string   "phylogenic_relationship"
    t.string   "uses"
    t.text     "toxicity"
    t.boolean  "has_children",                           :default => false, :null => false
    t.datetime "deleted_at"
    t.text     "description"
    t.string   "conservation_status"
    t.text     "editors"
    t.string   "basionym"
    t.text     "comments"
    t.text     "habitat"
    t.integer  "ubio_id"
    t.integer  "ncbi_id"
    t.string   "treebase_id"
    t.integer  "copied_from_id"
    t.string   "subsection",              :limit => nil
  end

  add_index "taxonomies", ["parent_taxon_id"], :name => "taxonomies_parent_taxon_id_idx"

  create_table "term", :primary_key => "term_id", :force => true do |t|
    t.string  "name",                      :null => false
    t.text    "definition"
    t.string  "identifier",  :limit => 40
    t.string  "is_obsolete", :limit => 1
    t.integer "ontology_id",               :null => false
  end

  add_index "term", ["identifier"], :name => "term_identifier_key", :unique => true
  add_index "term", ["name", "ontology_id", "is_obsolete"], :name => "term_name_key", :unique => true
  add_index "term", ["ontology_id"], :name => "term_ont"

  create_table "term_dbxref", :id => false, :force => true do |t|
    t.integer "term_id",   :null => false
    t.integer "dbxref_id", :null => false
    t.integer "rank"
  end

  add_index "term_dbxref", ["dbxref_id"], :name => "trmdbxref_dbxrefid"

  create_table "term_path", :primary_key => "term_path_id", :force => true do |t|
    t.integer "subject_term_id",   :null => false
    t.integer "predicate_term_id", :null => false
    t.integer "object_term_id",    :null => false
    t.integer "ontology_id",       :null => false
    t.integer "distance"
  end

  add_index "term_path", ["object_term_id"], :name => "trmpath_objectid"
  add_index "term_path", ["ontology_id"], :name => "trmpath_ontid"
  add_index "term_path", ["predicate_term_id"], :name => "trmpath_predicateid"
  add_index "term_path", ["subject_term_id", "predicate_term_id", "object_term_id", "ontology_id", "distance"], :name => "term_path_subject_term_id_key", :unique => true

  create_table "term_relationship", :primary_key => "term_relationship_id", :force => true do |t|
    t.integer "subject_term_id",   :null => false
    t.integer "predicate_term_id", :null => false
    t.integer "object_term_id",    :null => false
    t.integer "ontology_id",       :null => false
  end

  add_index "term_relationship", ["object_term_id"], :name => "trmrel_objectid"
  add_index "term_relationship", ["ontology_id"], :name => "trmrel_ontid"
  add_index "term_relationship", ["predicate_term_id"], :name => "trmrel_predicateid"
  add_index "term_relationship", ["subject_term_id", "predicate_term_id", "object_term_id", "ontology_id"], :name => "term_relationship_subject_term_id_key", :unique => true

  create_table "term_relationship_term", :id => false, :force => true do |t|
    t.integer "term_relationship_id", :null => false
    t.integer "term_id",              :null => false
  end

  add_index "term_relationship_term", ["term_id"], :name => "term_relationship_term_term_id_key", :unique => true

  create_table "term_synonym", :id => false, :force => true do |t|
    t.string  "synonym", :null => false
    t.integer "term_id", :null => false
  end

  create_table "timelines", :id => false, :force => true do |t|
    t.integer  "timeline_id",                  :null => false
    t.integer  "nid",             :limit => 8, :null => false
    t.datetime "deleted_at"
    t.integer  "copied_from_nid"
    t.integer  "project_id"
  end

  create_table "timestamps", :id => false, :force => true do |t|
    t.integer  "nid",   :limit => 8, :null => false
    t.datetime "value",              :null => false
  end

  create_table "user_vtattrs", :primary_key => "vtid", :force => true do |t|
    t.string  "username",                                         :null => false
    t.string  "email"
    t.string  "last_name"
    t.string  "first_name"
    t.string  "initials",        :limit => 5
    t.string  "institution"
    t.boolean "enabled",                       :default => false, :null => false
    t.string  "activation_code"
    t.string  "password",        :limit => 40
    t.string  "salt",            :limit => 40
    t.integer "old_id"
  end

  add_index "user_vtattrs", ["vtid"], :name => "user_vcattrs_vtid_key", :unique => true

  create_table "users", :primary_key => "user_id", :force => true do |t|
    t.integer  "rtid",                      :limit => 8,                     :null => false
    t.integer  "vtid",                      :limit => 8,                     :null => false
    t.integer  "owner_user_rtid",           :limit => 8,                     :null => false
    t.integer  "owner_record_rtid",         :limit => 8,                     :null => false
    t.integer  "owner_graph_rtid",          :limit => 8,                     :null => false
    t.integer  "owner_permission_set_rtid",                                  :null => false
    t.integer  "creator_rtid",              :limit => 8,                     :null => false
    t.datetime "created_at",                                                 :null => false
    t.integer  "updater_rtid",              :limit => 8,                     :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "username",                                                   :null => false
    t.string   "email"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "initials",                  :limit => 5
    t.string   "institution"
    t.boolean  "enabled",                                 :default => false, :null => false
    t.string   "activation_code"
    t.string   "password",                  :limit => 40
    t.string   "salt",                      :limit => 40
    t.integer  "old_id"
  end

  add_index "users", ["rtid"], :name => "users_rtid_key", :unique => true

  create_table "varchars", :id => false, :force => true do |t|
    t.integer "nid",   :limit => 8, :null => false
    t.string  "value",              :null => false
  end

  create_table "vsattrs", :primary_key => "vtid", :force => true do |t|
    t.integer  "rtid",         :limit => 8, :null => false
    t.integer  "creator_rtid", :limit => 8, :null => false
    t.integer  "deleter_rtid", :limit => 8
    t.datetime "created_at",                :null => false
    t.datetime "deleted_at"
  end

  create_table "wexec_paras", :force => true do |t|
    t.integer  "wexec_id"
    t.string   "pname"
    t.text     "pcaption"
    t.string   "ptype"
    t.string   "select_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wexecs", :force => true do |t|
    t.string   "name"
    t.text     "eloc"
    t.string   "inputs"
    t.string   "outputs"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wflows", :force => true do |t|
    t.text     "name"
    t.text     "desc"
    t.string   "wstatus"
    t.string   "wfolder"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.integer  "updater"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "workflows" because of following StandardError
#   Unknown type 'workflow_status' for column 'status'

  create_table "wtask_ports", :force => true do |t|
    t.integer  "wtask_id"
    t.integer  "ptype"
    t.text     "ploc"
    t.string   "pname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wtasks", :force => true do |t|
    t.integer  "wflow_id"
    t.integer  "exe_id"
    t.text     "inline"
    t.string   "name"
    t.string   "wtasks_status"
    t.string   "wtasks_folder"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "z_files", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zvi_file_name"
    t.string   "content_type"
    t.integer  "file_size"
    t.integer  "project_id",       :null => false
    t.string   "caption"
    t.date     "uploaded_at_date"
    t.integer  "user_id"
  end

end
