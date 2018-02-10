# encoding: UTF-8

# KLayout Layout Viewer
# Copyright (C) 2006-2018 Matthias Koefferlein
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

if !$:.member?(File::dirname($0))
  $:.push(File::dirname($0))
end

load("test_prologue.rb")

# Tests for the klayout executable
#
# This tests actually runs inside a KLayout/unit_tests instance but 
# only for providing the test automation.

class KLayoutMain_TestClass < TestBase

  def test_1

    # Basic
    version = `./klayout -v`
    assert_equal(version, "#{RBA::Application.instance.version}\n")

  end

  def test_2

    # Basic Ruby
    out = `./klayout -b -rd v1=42 -rd v2=hello -r #{File.join(File.dirname(__FILE__), "test.rb")}`
    assert_equal(out, "Variable v1=42 v2=hello\n")

    out = `./klayout -b -rd v1=42 -rd v2=hello -r #{File.join(File.dirname(__FILE__), "test.rb")} -rm #{File.join(File.dirname(__FILE__), "test2.rb")} -rm #{File.join(File.dirname(__FILE__), "test3.rb")}`
    assert_equal(out, "test2\ntest3\nVariable v1=42 v2=hello\n")

  end

  def test_3

    # Basic Python
    out = `./klayout -b -rd v1=42 -rd v2=hello -r #{File.join(File.dirname(__FILE__), "test.py")}`
    assert_equal(out, "Variable v1=42 v2=hello\n")

  end

  def test_4

    # Application class

    # QCoreApplication for (headless) mode
    out = `./klayout -b -r #{File.join(File.dirname(__FILE__), "test_app.rb")}`
    assert_equal(out, "RBA::Application superclass RBA::QCoreApplication_Native\nMainWindow is not there\n")

    # QApplication for GUI mode
    out = `./klayout -z -nc -rx -r #{File.join(File.dirname(__FILE__), "test_app.rb")}`
    assert_equal(out, "RBA::Application superclass RBA::QApplication_Native\nMainWindow is there\n")

  end

  def test_5

    # Script variables
    out = `./klayout -b -wd tv1=17 -wd tv2=25 -wd tv3 -r #{File.join(File.dirname(__FILE__), "test_script.rb")}`
    assert_equal(out, "42\ntrue\n")

  end

  def test_6

    # Editable / Non-editable mode
    out = `./klayout -b -ne -r #{File.join(File.dirname(__FILE__), "test_em.rb")}`
    assert_equal(out, "false\n")

    out = `./klayout -b -e -r #{File.join(File.dirname(__FILE__), "test_em.rb")}`
    assert_equal(out, "true\n")

  end

  def test_7

    cfg_file = File.join($ut_testtmp, "config.xml")
    File.open(cfg_file, "w") { |file| file.puts("<config/>") }

    # Special configuration file
    `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_set_config1.rb")}`

    out = `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_read_config.rb")}`
    assert_equal(out, "42\n")

    # Update
    `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_set_config2.rb")}`

    out = `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_read_config.rb")}`
    assert_equal(out, "17\n")

    # Reset
    `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_set_config1.rb")}`

    out = `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_read_config.rb")}`
    assert_equal(out, "42\n")

    # No update
    `./klayout -b -t -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_set_config2.rb")}`

    out = `./klayout -b -c #{cfg_file} -r #{File.join(File.dirname(__FILE__), "test_read_config.rb")}`
    assert_equal(out, "42\n")

  end

  def test_8

    # Loading layouts
    out = `./klayout -z -nc -rx #{File.join(File.dirname(__FILE__), "test1.gds")} -r #{File.join(File.dirname(__FILE__), "test_lay.rb")}`
    assert_equal(out, "TOP1\n")

    out = `./klayout -z -nc -rx #{File.join(File.dirname(__FILE__), "test1.gds")} #{File.join(File.dirname(__FILE__), "test2.gds")} -r #{File.join(File.dirname(__FILE__), "test_lay2.rb")}`
    assert_equal(out, "TOP1\nTOP2\n")

    out = `./klayout -z -nc -rx #{File.join(File.dirname(__FILE__), "test1.gds")} #{File.join(File.dirname(__FILE__), "test2.gds")} -s -r #{File.join(File.dirname(__FILE__), "test_lay2.rb")}`
    assert_equal(out, "TOP1;TOP2\n")

  end

  def test_9

    # Sessions
    out = `./klayout -z -nc -rx -u #{File.join(File.dirname(__FILE__), "session.lys")} -r #{File.join(File.dirname(__FILE__), "test_lay2.rb")}`
    assert_equal(out, "TOP2;TOP1\n")

  end

end

load("test_epilogue.rb")