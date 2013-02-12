class Role < Record

  has_many :role_member_users, foreign_key: :subj_rtid, primary_key: :rtid
  has_many :member_users, through: :role_member_users
  has_many :permissions, foreign_key: :role_rtid, primary_key: :rtid
  has_many :permissions_2, class_name: 'Permission', foreign_key: :role_rtid, primary_key: :rtid # duplicate for purpose of multi-join/include - grep to see examples

#  def users
#    User.
#      joins(
#        :in_statements => {
#          :property => {
#            :vsattrs => :vtattrs
#          },
#        }
#      ).
#      where(
#        :in_statements => {
#          :property => {
#            :vsattrs => {
#              :vtattrs => {
#                :label => 'rdfs:member'
#              }
#            }
#          },
#          :subj_rtid => self.rtid
#        }
#      )
#  end
end