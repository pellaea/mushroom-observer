# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../boot.rb')

class LanguageTest < UnitTestCase

  def test_official
    english = languages(:english)
    all_but_english = Language.all - [english]
    assert_objs_equal(english, Language.official)
    assert_obj_list_equal(all_but_english, Language.unofficial)
  end

  def test_top_contributors
    english = languages(:english)
    french = languages(:french)
    greek = languages(:greek)
    assert_equal([], english.top_contributors)
    assert_equal([[2, 'mary'], [1, 'rolf']], french.top_contributors)
    assert_equal([[2, 'mary']], french.top_contributors(1))
    assert_equal([[4, 'dick']], greek.top_contributors)
  end

  def test_update_localization
    str = translation_strings(:english_one)
    str.text = 'shazam'
    str.update_localization
    assert_equal('shazam', :one.l)

    str = translation_strings(:french_one)
    str.text = 'la chazame'
    str.update_localization
    assert_equal('shazam', :one.l)
    Locale.code = str.language.locale
    assert_equal('la chazame', :one.l)
  end

  def set_text(str, new_string)
    str.text = new_string
    str.save
    str.reload
  end
  
  def test_versioning_twice
    str = translation_strings(:version_wizard)
    yesterday = Time.now - 1.day
    assert(str.updated_at < yesterday)
    expected_version = str.version + 1
    User.current = str.user
    set_text(str, 'Gandalf the Gray')
    assert(str.updated_at > yesterday)
    assert_equal(expected_version, str.version)
    set_text(str, "Gandalf the White")
    assert_equal(expected_version, str.version)
  end

  def test_versioning_someone_else
    str = translation_strings(:version_wizard)
    User.current = str.user
    set_text(str, 'Gandalf the Gray')
    expected_version = str.version + 1
    User.current = users(:katrina)
    assert_not_equal(str.user_id, User.current_id)
    set_text(str, "Mithrandir")
    assert_equal(expected_version, str.version)
  end
  
  def test_update_recent_translations
    one = translation_strings(:english_waiting_for_update)
    old_val = one.tag.to_sym.l
    new_val = one.text
    assert_not_equal(old_val, new_val)
    Language.last_update = one.updated_at + 1.minute
    Language.update_recent_translations
    assert_equal(old_val, one.tag.to_sym.l)
    Language.last_update = one.updated_at - 1.minute
    Language.update_recent_translations
    assert_equal(new_val, one.tag.to_sym.l)
  end

  def test_score_lines
    len = Language::CHARACTERS_PER_LINE
    assert_equal(0, Language.score_lines(''))
    assert_equal(1, Language.score_lines('x'))
    assert_equal(1, Language.score_lines('x'*(len-1)))
    assert_equal(2, Language.score_lines('x'*len))
    assert_equal(1, Language.score_lines("x\nx\nx"))
    assert_equal(3, Language.score_lines("x\ny\nz"))
    assert_equal(2, Language.score_lines("x\n\ny\n\nx"))
  end

  def test_user_contribution
    # These are smaller than they should be because the test fixtures doesn't
    # include versions corresponding to the current translation strings.
    assert_equal(0, Language.calculate_users_contribution(@rolf))
    assert_equal(1, Language.calculate_users_contribution(@mary))
    assert_equal(1, Language.calculate_users_contribution(@dick))
    assert_equal(0, languages(:english).calculate_users_contribution(@mary))
    assert_equal(1, languages(:greek).calculate_users_contribution(@mary))
    assert_equal(0, languages(:english).calculate_users_contribution(@dick))
    assert_equal(1, languages(:greek).calculate_users_contribution(@dick))
  end
end
