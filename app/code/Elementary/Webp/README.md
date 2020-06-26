# Magento 2 Webp

This module adds WebP support to Magento 2

# Version:
1.0.0

# Developers:
Arnolds Kozlovskis

## Installation

To use this module in Magento 2, first you will need to modify the projects `composer.json` file. In the repositories node, you will need to add this block so that the module can be retrieved:

```
{
    "type": "vcs",
    "url": "git@bitbucket.org:elementarydigital/magento2-module-webp.git"
}
```

Once this has been done, you can then run the command `composer require elementarydigital/magento2-webp` to add the module to the project. When this has been done, go to the `bin` folder in the magento 2 project and then to the following

1. run the module enabling command `php magento module:enable Elementary_Webp`
2. run the upgrade command with `php magento setup:upgrade`
3. run the static content command with the stores language so if its uk english it would be `php magento setup:static-content:deploy en_GB`

## User Guide

This module adds WebP support to Magento 2, and also provides the ability to lazy load images.
