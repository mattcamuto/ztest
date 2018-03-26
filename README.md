# Ztest

Simple implementation of the zend quiz, which was to write a small search app. 
In this implementation I wrote the search engine from scratch after doing 
some research on engines. I did this to work on breaking down the code into re-usable
and swap-able units that can could be extended in the future. A small example demo app
is included. The integration specs use the same zend fixtures as the app. This allows for consistency
and a real world working data set. 

The implementation is modular and the following functions are separate:

  * Invert Index (Inverted keyword index, does not account for term frequency)
  * Document store (Stores the actual raw docs)
  * Document tokenizer (Split out all terms in a hash)
  * Document validator
  * Custom field parsers (For example split and break a date field)
  * Custom field filters (For example 'no words less than 3 characters')
  * Custom has-many finder (for auto relation building)
  * View presenter (for custom title fields and tabular presentation) 
  * Cli-Runner (Built on top of tty-prompt and tty-table gems) 
    
The invert index has the following propertied 
  * All keys are strings (non string converted to string)
  * All strings are trimmed and downcase
  * Blank fields will be indexed
    
Thus our searches will not be case sensitive. Also note that string fields
do not currently remove 'special characters'. In in ideal world the string '(Matt)' should 
be index with both '(matt)' and 'matt'. In this case the latter is not true... yet!

The application also has custom and configurable 'has-many' finders. This allows for eager loading 
and post load filtering. This will avoid doing an 'n+1' when loading say a list of users and then associated
tickets. A 'belongs-to' implementation was not implemented, sadly. But would have been a nice addition.
     
The `zrtest/demo` directory features the `demo_cli` class which will drive the 
 search off of the zend data. The `demo_index_builder` class is simply a factory to assemble all 
 the components. This in in liu of a much more complex configuration/discovery system like a real
 application would have.
  
## Installation

This project was build using a gem configuration. The gem layout 
gives you some nice pre-cooked structure which is easy to bootstrap.

For this project all you need to do is run bundler.

    $ bundle

## Usage

To use the simple cli app simply type:

     bin/demo_cli
     
This will allow you to run the interactive CLI app. You simple use the
mouse to drive the cli and can type in only the search term you want. In the cli app 'Control-C' 
will always bring you back to the home menu, from which you can 'QUIT' from the app.

## Tests

The code is tests with rspec. Code coverage should be high and tests span both 
unit and integration. The only class that is not tested, sadly, is the `DemoCli` class which 
is the small cli wrapper. I was having a hard time finding a way to property and easily 
externally drive the cli app (Wanted to do capybara for a shell-app). To run simply type:

     bundle exec rspec
     
Also include is guard, if you are developing and test-driving and adding features. To use simply:
     
     bundle exec guard

The associated `Guardile` has the default configuration. It has not been pruned.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/Ztest/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
