// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/utilities
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/hashtags

((exports) => {
  const { collapsedMenu, options, categories } = exports.AwesomeMap;
  const layers = {};
  const cluster = L.markerClusterGroup({
    iconCreateFunction: function(cluster) {
      return L.divIcon({ html: cluster.getAllChildMarkers().length, className: 'map-cluster', iconSize: L.point(40, 40) });
    }
  });

  const control = L.control.layers(null, null, {
    position: 'topleft',
    sortLayers: false,
    collapsed: collapsedMenu,
    // hideSingleBase: true
  });

  // Don't add control layer
  const addProposalsControls = (map, component) => {};
  const addMeetingsControls = (map, component) => {};
  const addSearchControls = () => {};
  const addCategoriesControls = (map) => {};
  const addHashtagsControls = (map, hashtags, marker) => {};

  exports.AwesomeMap.layers = layers;
  exports.AwesomeMap.control = control;
  exports.AwesomeMap.cluster = cluster;
  exports.AwesomeMap.addProposalsControls = addProposalsControls;
  exports.AwesomeMap.addMeetingsControls = addMeetingsControls;
  exports.AwesomeMap.addSearchControls = addSearchControls;
  exports.AwesomeMap.addCategoriesControls = addCategoriesControls;
  exports.AwesomeMap.addHashtagsControls = addHashtagsControls;
  exports.AwesomeMap.hashtagAdded = $.noop;
})(window);
