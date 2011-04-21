#!/usr/bin/env watchr
# Run me with:
# $ watchr specs.watchr

# --------------------------------------------------
# Rules
# --------------------------------------------------
watch( '^spec/.*_spec\.rb' )  { |m| ruby m[0] }
watch( '^lib/(.*)\.rb' )      { |m| ruby "spec/#{m[1]}_spec.rb" }
watch( '^lib/selo_ring/(.*)\.rb' ) { |m| ruby "spec/#{m[1]}_spec.rb" }
watch( '^spec/spec_helper\.rb' ) { ruby specs }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('QUIT') { ruby specs } # Ctrl-\
Signal.trap('INT' ) { abort("bye\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------
def ruby(*paths)
  run "ruby -I.:lib:spec -e'%w( #{paths.flatten.join(' ')} ).each {|p| require p }'"
end

def specs
  Dir['spec/**/*_spec.rb'] - ['spec/spec_helper.rb']
end

def run( cmd )
  puts cmd
  system cmd
end
