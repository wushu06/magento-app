<?php

namespace Elementary\Webp\Plugin;

use Exception as ExceptionAlias;
use Magento\Framework\DomDocument\DomDocumentFactory;
use Magento\Framework\View\LayoutInterface;
use Yireo\Webp2\Block\Picture;
use Yireo\Webp2\Config\Config;
use Yireo\Webp2\Image\Convertor;
use Yireo\Webp2\Image\File;
use Yireo\Webp2\Logger\Debugger;

/**
 * Replace Tags
 *
 * @package   Elementary\Webp
 * @copyright Elementary Digital - 2020
 */
class ReplaceTags
{
    /**
     * @var Convertor
     */
    private $convertor;

    /**
     * @var File
     */
    private $file;

    /**
     * @var Debugger
     */
    private $debugger;

    /**
     * @var Config
     */
    private $config;

    /**
     * @var DomDocumentFactory
     */
    private $domDocumentFactory;

    /**
     * ReplaceTags constructor.
     *
     * @param Convertor $convertor
     * @param File $file
     * @param Debugger $debugger
     * @param Config $config
     */
    public function __construct(
        Convertor $convertor,
        File $file,
        Debugger $debugger,
        Config $config,
        DomDocumentFactory $domDocumentFactory
    ) {
        $this->convertor = $convertor;
        $this->file = $file;
        $this->debugger = $debugger;
        $this->config = $config;
        $this->domDocumentFactory = $domDocumentFactory;
    }

    /**
     * Interceptor of getOutput()
     *
     * This method will exclude any images that are added via Magezon Pagebuilder as a `Single Image` as that module already has srcset setup for responsive images
     *
     * @param LayoutInterface $layout
     * @param string $output
     * @return string
     * @throws ExceptionAlias
     */
    public function afterGetOutput(LayoutInterface $layout, string $output): string
    {
        $handles = $layout->getUpdate()->getHandles();
        if (empty($handles)) {
            return $output;
        }

        $skippedHandles = [
            'webp_skip',
            'sales_email_order_invoice_items'
        ];
        if (array_intersect($skippedHandles, $handles)) {
            return $output;
        }

        if ($this->config->enabled() === false) {
            return $output;
        }

        $regex = '/<([^<]+)\ src=\"([^\"]+)\.(png|jpg|jpeg)([^>]+)>/mi';
        if (preg_match_all($regex, $output, $matches, PREG_OFFSET_CAPTURE) === false) {
            return $output;
        }

        $accumulatedChange = 0;

        foreach ($matches[0] as $index => $match) {
            $offset = $match[1] + $accumulatedChange;
            $htmlTag = $matches[0][$index][0];
            $imageUrl = $matches[2][$index][0] . '.' . $matches[3][$index][0];

            $webpUrl = $this->file->toWebp($imageUrl);

            $altText = $this->getAttributeText($htmlTag, 'alt');
            $width = $this->getAttributeText($htmlTag, 'width');
            $height = $this->getAttributeText($htmlTag, 'height');
            $class = $this->getAttributeText($htmlTag, 'class');

            // This is to get around the issue of responsive srcset images not working in Magezon PageBuilder
            if (strpos($class, 'mgz-hover-main') !== false) {
                continue;
            }

           

            try {
                $result = $this->convertor->convert($imageUrl, $webpUrl);
            } catch (ExceptionAlias $e) {
                if ($this->config->isDebugging()) {
                    throw $e;
                }

                $result = false;
                $this->debugger->debug($e->getMessage(), [$imageUrl, $webpUrl]);
            }

            if (!$result && !$this->convertor->urlExists($webpUrl)) {
                continue;
            }

            $newHtmlTag = $this->getPictureBlock($layout)
                ->setOriginalImage($imageUrl)
                ->setWebpImage($webpUrl)
                ->setAltText($altText)
                ->setOriginalTag($htmlTag)
                ->setClass($class)
                ->setWidth($width)
                ->setHeight($height)
                ->toHtml();

            $newHtmlTag = $this->makeLazy($newHtmlTag);

            $output = substr_replace($output, $newHtmlTag, $offset, strlen($htmlTag));
            $accumulatedChange = $accumulatedChange + (strlen($newHtmlTag) - strlen($htmlTag));
        }

        return $output;
    }

    /**
     * @param string $htmlTag
     * @param string $attribute
     * @return string
     */
    private function getAttributeText(string $htmlTag, string $attribute): string
    {
        if (preg_match('/\ ' . $attribute . '=\"([^\"]+)/', $htmlTag, $match)) {
            $altText = $match[1];
            $altText = strtr($altText, ['"' => '', "'" => '']);
            return $altText;
        }

        return '';
    }

    /**
     * Get Picture Block-class from the layout
     *
     * @param LayoutInterface $layout
     * @return Picture
     */
    private function getPictureBlock(LayoutInterface $layout): Picture
    {
        /** @var Picture $block */
        $block = $layout->createBlock(Picture::class);
        $block->setDebug($this->config->isDebugging());
        return $block;
    }

    /**
     * Add necessary attributes to `img` tag to enable lazy loading.
     *
     * @param $newHtmlTag
     * @return mixed
     */
    private function makeLazy($newHtmlTag)
    {
        $dom = $this->domDocumentFactory->create();
        // @ - used to suppress errors for HTML5 elements
        @$dom->loadHTML($newHtmlTag, LIBXML_HTML_NOIMPLIED | LIBXML_HTML_NODEFDTD);

        foreach ($dom->getElementsByTagName('img') as $image) {
            $this->setLazyClass($image);
            $this->setLazySrc($image);
        }

        return $dom->saveHtml();
    }

    /**
     * Add lazy class, either on it's own or append it.
     *
     * @param $image
     * @return mixed
     */
    private function setLazyClass(&$image)
    {
        $classes = $image->getAttribute('class') ? $image->getAttribute('class') . ' lazy' : 'lazy';

        $image->setAttribute('class', $classes);

        return $image;
    }

    /**
     * Replace `src` attribute, with `data-src`.
     *
     * @param $image
     * @return mixed
     */
    private function setLazySrc(&$image)
    {
        $src = $image->getAttribute('src');

        $image->setAttribute('data-src', $src);
        $image->removeAttribute('src');

        return $image;
    }
}
