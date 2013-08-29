# encoding: utf-8
#
#  = License Model
#
#  Very simple model to hold info about a copyright license.  Originally
#  intended for use by Image, but now extended to Name Descriptions.
#
#  == Deprecation
#
#  Instead of deleting out-dated License's, since that would involve finding
#  and updating thousands of records, we just "deprecate" them instead.  This
#  has the effect of removing it from pulldown menus in the HTML forms.
#
#  == Attributes
#
#  id::           Locally unique numerical id, starting at 1.
#  sync_id::      Globally unique alphanumeric id, used to sync with remote servers.
#  updated_at::   Date/time it was last updated.
#  deprecated::   Has this been deprecated?
#  display_name:: Name, e.g., "Creative Commons Non-commercial v2.5"
#  form_name::    Code, e.g., "ccbyncsa25"
#  url::          URL,  e.g., "http://creativecommons.org/licenses/by-nc-sa/2.5/"
#
#  == Class methods
#
#  current_names_and_ids::  List non-deprecated License names/ids.
#
#  == Instance methods
#
#  images::                 Array of Image's that use this License.
#  users::                  Array of User's for whom this is the default License.
#  location_descriptions::  Array of Name's that use this License.
#  name_descriptions::      Array of Name's that use this License.
#  text_name::              Alias for +display_name+ for debugging.
#
#  == Callbacks
#
#  None.
#
################################################################################

class License < AbstractModel
  has_many :images
  has_many :location_descriptions
  has_many :name_descriptions
  has_many :users

  PREFERRED_LICENSE_FORM_NAME = 'ccbysa30'

  # Use this license if all else equal.
  def self.preferred
    License.find_by_form_name(PREFERRED_LICENSE_FORM_NAME)
  end

  # Various debugging things require all models respond to text_name.  Just
  # returns +display_name+.
  def text_name
    display_name.to_s
  end

  # Get list of non-deprecated License's.  Returns an Array of pairs (such as
  # would be needed by a pulldown menu helper):
  #
  #   for name, id in License.current_names_and_ids
  #     puts "license ##{id}: '#{name}'"
  #   end
  #
  def self.current_names_and_ids(current_license=nil)
    result = License.find(:all, :conditions => "deprecated = 0").
                     map {|l| [l.display_name, l.id]}
    if current_license
      if current_license.deprecated
        result.push([current_license.display_name, current_license.id])
      end
    end
    result
  end
  
  def copyright_text(year, name)
    if self.form_name == 'publicdomain'
      "#{:image_show_public_domain.t} #{name}"
    else
      "#{:image_show_copyright.t} &copy; #{year} #{name}"
    end
  end
end
