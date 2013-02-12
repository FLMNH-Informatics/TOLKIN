require 'db/migrate/essential/create_v_users'
require 'db/migrate/essential/create_v_users_constraints'

class SchemaSupplement < ActiveRecord::Migration
  def self.up
    execute %{
CREATE OR REPLACE VIEW v_collections AS
 SELECT collections.id, collections.collector, collections.associate_collectors, collections.prefix, collections.collection_number, collections.suffix, collections.coll_start_date, collections.coll_end_date, collections.verbatim_coll_date, collections.herbarium, collections.country, collections.state_province, collections.county, collections.island, collections.latitude, collections.longitude, collections.accuracy, collections.source_url, collections.label_text, collections."desc", collections.fruiting, collections.flowering, collections.vegetation, collections.geology, collections.date_trans, collections.notes, collections.recpermission_id, collections.taxonomy_id, collections.annotations, collections.elevation_start, collections.elevation_end, collections.elevation_unit, collections.last_updated_by, collections.silica_sample, collections.user_id, collections.project_id, collections.created_at, collections.updated_at, collections.length_unit_id, collections.locality, collections.long_min, collections.long_sec, collections.long_dir, collections.long_degree, collections.lat_min, collections.lat_sec, collections.lat_dir, collections.lat_degree, collections.institution_code, collections.higher_geography, collections.continent, collections.accuracy_other, collections.plant_description, collections.identification_qualifier, collections.max_depth_in_meters, collections.min_depth_in_meters, collections.collecting_method, collections.valid_distribution_flag, collections.image_url, collections.type_name, collections.type_status, collections.guid, collections.old_tolkin_id, collections.barcode, collections.accession_num,
        CASE
            WHEN collections.collector IS NOT NULL AND btrim(collections.collector::text) <> ''::text AND collections.collection_number IS NOT NULL AND btrim(collections.collection_number::text) <> ''::text THEN (collections.collector::text || ' '::text) || collections.collection_number::text
            ELSE ''::text
        END AS label
   FROM collections;

ALTER TABLE v_collections OWNER TO tolkin2;

CREATE OR REPLACE VIEW v_people AS
 SELECT people.id, people.first_name, people.middle_name, people.last_name, people.exaternal_id, people.prefix, people.suffix, people.image_url, people.phone, people.email, people.im, people.office_address_line_one, people.office_address_line_two, people.office_city, people.office_state, people.office_zip, people.research_focus, people.active, people.scoring_hash, people.created_at, people.updated_at, people.project_id, people.user_id, people.initials, people.country, people.fax, people.institution,
        CASE
            WHEN people.first_name IS NOT NULL AND btrim(people.first_name::text) <> ''::text AND people.last_name IS NOT NULL AND btrim(people.last_name::text) <> ''::text THEN ((people.first_name::text || ' '::text) || people.last_name::text) || ' '::text
            WHEN people.first_name IS NOT NULL AND btrim(people.first_name::text) <> ''::text THEN people.first_name::text
            WHEN people.last_name IS NOT NULL AND btrim(people.last_name::text) <> ''::text THEN people.last_name::text
            ELSE ''::text
        END AS label
   FROM people;

ALTER TABLE v_people OWNER TO tolkin2;


      CREATE OR REPLACE VIEW v_taxonomies AS
      SELECT *,
        CASE
            WHEN taxonomies.author IS NOT NULL AND btrim(taxonomies.author::text) <> ''::text AND taxonomies.year IS NOT NULL AND btrim(taxonomies.year::text) <> ''::text THEN ((((taxonomies.name::text || ' '::text) || taxonomies.author::text) || ' '::text) || taxonomies.year::text)::character varying
            WHEN taxonomies.author IS NOT NULL AND btrim(taxonomies.author::text) <> ''::text THEN ((taxonomies.name::text || ' '::text) || taxonomies.author::text)::character varying
            ELSE taxonomies.name
        END AS label,
        CASE
            WHEN taxonomies.publication IS NOT NULL AND btrim(taxonomies.publication::text) <> ''::text AND taxonomies.volume_num IS NOT NULL AND btrim(taxonomies.volume_num::text) <> ''::text AND taxonomies.pages IS NOT NULL AND btrim(taxonomies.pages::text) <> ''::text THEN ((((taxonomies.publication::text || ' '::text) || taxonomies.volume_num::text) || ' '::text) || taxonomies.pages::text)::character varying
            WHEN taxonomies.publication IS NOT NULL AND btrim(taxonomies.publication::text) <> ''::text AND taxonomies.volume_num IS NULL AND btrim(taxonomies.volume_num::text) = ''::text AND taxonomies.pages IS NOT NULL AND btrim(taxonomies.pages::text) <> ''::text THEN ((taxonomies.publication::text || ' '::text) || taxonomies.pages::text)::character varying
            WHEN taxonomies.publication IS NOT NULL AND btrim(taxonomies.publication::text) <> ''::text AND taxonomies.volume_num IS NOT NULL AND btrim(taxonomies.volume_num::text) <> ''::text AND taxonomies.pages IS NULL AND btrim(taxonomies.pages::text) = ''::text THEN ((taxonomies.publication::text || ' '::text) || taxonomies.volume_num::text)::character varying
            WHEN taxonomies.publication IS NULL AND btrim(taxonomies.publication::text) = ''::text AND taxonomies.volume_num IS NOT NULL AND btrim(taxonomies.volume_num::text) <> ''::text AND taxonomies.pages IS NOT NULL AND btrim(taxonomies.pages::text) <> ''::text THEN ((taxonomies.volume_num::text || ' '::text) || taxonomies.pages::text)::character varying
            WHEN taxonomies.publication IS NULL AND btrim(taxonomies.publication::text) = ''::text AND taxonomies.volume_num IS NULL AND btrim(taxonomies.volume_num::text) = ''::text AND taxonomies.pages IS NOT NULL AND btrim(taxonomies.pages::text) <> ''::text THEN taxonomies.pages::text::character varying
            WHEN taxonomies.publication IS NULL AND btrim(taxonomies.publication::text) = ''::text AND taxonomies.volume_num IS NOT NULL AND btrim(taxonomies.volume_num::text) <> ''::text AND taxonomies.pages IS NULL AND btrim(taxonomies.pages::text) = ''::text THEN taxonomies.volume_num::text::character varying
            ELSE taxonomies.publication
        END AS publication_info
   FROM taxonomies;

}

    CreateVUsers.up
    CreateVUsersConstraints.up
  end
end