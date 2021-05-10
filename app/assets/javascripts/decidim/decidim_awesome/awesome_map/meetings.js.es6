// = require decidim/decidim_awesome/awesome_map/api_fetcher
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/utilities

((exports) => {
  const { getCategory, truncate } = exports.AwesomeMap;
  const query = `query ($id: ID!, $after: String!) {
    component(id: $id) {
        id
        __typename
        ... on Meetings {
          meetings(first: 50, after: $after) {
            pageInfo {
              hasNextPage
              endCursor
            }
            edges {
              node {
                id
                title {
                  translations {
                    text
                    locale
                  }
                }
                description {
                  translations {
                    text
                    locale
                  }
                }
                startTime
                location {
                  translations {
                    text
                    locale
                  }
                }
                address
                locationHints {
                  translations {
                    text
                    locale
                  }
                }
                coordinates {
                  latitude
                  longitude
                }
                category {
                  id
                }
              }
            }
          }
        }
      }
    }`;

  const MeetingIcon = L.DivIcon.SVGIcon.extend({
    options: {
      fillColor: "#000",
      iconSize: { x: 30, y: 30 },
      opacity: 0
    },
    _createPathDescription: function() {
      return "M3 0c-1.66 0-3 1.34-3 3 0 2 3 5 3 5s3-3 3-5c0-1.66-1.34-3-3-3zm0 1c1.11 0 2 .9 2 2 0 1.11-.89 2-2 2-1.1 0-2-.89-2-2 0-1.1.9-2 2-2z";
    },
    _createCircle: function() {
      return ""
    },
    // Improved version of the _createSVG, essentially the same as in later
    // versions of Leaflet. It adds the `px` values after the width and height
    // CSS making the focus borders work correctly across all browsers.
    _createSVG: function() {
      const path = this._createPath();
      const circle = this._createCircle();
      const text = this._createText();
      const className = `${this.options.className}-svg`;

      const style = `width:${this.options.iconSize.x}px; height:${this.options.iconSize.y}px;`;

      const svg = `<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="${className}" style="${style}" viewBox="0 0 8 8">${path}${circle}${text}</svg>`;

      return svg;
    }
  });

  const createMarker = (element, callback) => {
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      // icon: new MeetingIcon()
      icon: L.divIcon({ className: 'map-point', iconSize: L.point(20, 20) })
    });

    element.title.translation = ApiFetcher.findTranslation(element.title.translations);
    element.description.translation = truncate(ApiFetcher.findTranslation(element.description.translations)).replace(/\n/g, "<br>");
    element.location.translation = ApiFetcher.findTranslation(element.location.translations);
    element.locationHints.translation = ApiFetcher.findTranslation(element.locationHints.translations);
    callback(element, marker);
  };

  const fetchMeetings = (component, after, callback, finalCall = () => {}) => {

    const variables = {
      "id": component.id,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if (result) {
        result.component.meetings.edges.forEach((element) => {
          if (!element.node) return;

          if (element.node.coordinates) {
            element.node.link = component.url + '/meetings/' + element.node.id;
            createMarker(element.node, callback);
          }
        });

        if (result.component.meetings.pageInfo.hasNextPage) {
          fetchMeetings(component, result.component.meetings.pageInfo.endCursor, callback, finalCall);
        } else {
          finalCall();
        }
      }
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchMeetings = fetchMeetings;
})(window);
