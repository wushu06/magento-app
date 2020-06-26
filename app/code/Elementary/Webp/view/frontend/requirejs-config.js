var config = {
	map: {
		'*': {
			'lazyupdate': 'Elementary_Webp/js/lazyupdate'
		}
	},
    deps: [
        'Elementary_Webp/js/lazy'
    ],
    'shim': {
    	'lazyupdate': {
    		'deps': [
    			'Elementary_Webp/js/lazy'
    		]
    	}
    },
    'paths': {
        'lazyload': 'Elementary_Webp/js/vendor/lazyload.min',
    }
};
