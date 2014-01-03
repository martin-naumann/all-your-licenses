All your licenses
=================
...are belong to us!
--------------------

#Important legal note
The output of this script is not legally binding and may be totally wrong. Any use is at *your own risk*.
I do not take responsibility for any claims or damage this may incur!

#What's the problem?
Modern software is modular - and lots of those modules come in as external dependencies.

Besides aspects of quality assurance, maintainability and security, also legal considerations come into play!

Each dependency can have a different license with different implications for your own works' licensing and legal state - *so you better know all the licenses of your dependencies*!

I guess you don't right? But fear not!

#All your licenses are belong to you :)

This handy little script parses Gemfiles or package.json files for dependencies and tries to figure out their licenses for you.

## Npm modules
In the case of NPM this is rather simple as NPM comes with a default license so most of the modules have their license clearly stated on the npmjs.org website - easily parsable for this script, yay!

## Ruby gems
Ruby gems do not have a default license of choice, so a fair amount of gems does not even state their license, some only in the README some others in the LICENSE file, so we're trying

1. To get the license from rubygems.org
2. To get it from going to their github repo and read the LICENSE file
3. Shrugging and moving on...

# Cool, get me the licensez, then!
Just clone the repo and run

  bundle install
  ruby main.rb -f /path/to/a/Gemfile-or-package.json
or get help via

  ruby main.rb -h
  
The output may look like this:

  rake: MIT
  rdoc: Ruby
  fdoc: Apache 2.0
  Found 3 licenses from 3 dependencies
  MIT: 1x
  Ruby: 1x
  Apache 2.0: 1x
