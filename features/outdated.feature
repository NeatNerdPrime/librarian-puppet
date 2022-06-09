Feature: cli/outdated
  Puppet librarian needs to print outdated modules

  Scenario: Running outdated with forge modules
    Given a file named "Puppetfile" with:
    """
    forge "https://forgeapi.puppetlabs.com"

    mod 'puppetlabs/stdlib', '>=3.1.x'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: https://forgeapi.puppetlabs.com
      specs:
        puppetlabs/stdlib (3.1.0)

    DEPENDENCIES
      puppetlabs/stdlib (~> 3.0)
    """
    When I successfully run `librarian-puppet outdated`
    And the output should match:
    """
    ^puppetlabs-stdlib \(3\.1\.0 -> [\.\d]+\)$
    """

  Scenario: Running outdated with git modules
    Given a file named "Puppetfile" with:
    """
    forge "https://forgeapi.puppetlabs.com"

    mod 'test', :git => 'https://github.com/voxpupuli/librarian-puppet.git', :path => 'features/examples/test'
    """
    And a file named "Puppetfile.lock" with:
    """
    FORGE
      remote: https://forgeapi.puppetlabs.com
      specs:
        puppetlabs/stdlib (3.1.0)

    GIT
      remote: https://github.com/voxpupuli/librarian-puppet.git
      path: features/examples/test
      ref: master
      sha: 10fdf98190a7a22e479628b3616f17f48a857e81
      specs:
        test (0.0.1)
          puppetlabs/stdlib (>= 0)

    DEPENDENCIES
      test (>= 0)
    """
    When I successfully run `librarian-puppet outdated`
    And PENDING the output should match:
    # """
    # ^puppetlabs-stdlib \(3\.1\.0 -> [\.\d]+\)$
    # ^test .*$
    # """
