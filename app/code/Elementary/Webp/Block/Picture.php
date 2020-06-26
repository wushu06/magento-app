<?php

namespace Elementary\Webp\Block;

use Yireo\Webp2\Block;

/**
 * Picture Block
 *
 * @package   Elementary\Webp
 * @copyright Elementary Digital - 2020
 */
class Picture extends Block\Picture
{
    /**
     * @inheritdoc
     */
    protected $_template = 'Elementary_Webp::picture.phtml';
}
