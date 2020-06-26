define([
    'jquery',
    'lazyload'
], function ($, LazyLoad) {
    'use strict';

    window.lazyLoadInstance = new LazyLoad({
	    elements_selector: '.lazy'
	});
});
