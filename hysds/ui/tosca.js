const React = require("react"); // lgtm [js/unused-local-variable]

// DEFINING THE OPTIONS FOR THE LEAFLET MAP
exports.DISPLAY_MAP = true;

// all leaflet styles: https://leaflet-extras.github.io/leaflet-providers/preview/
exports.LEAFLET_TILELAYER =
  "https://{s}.basemaps.cartocdn.com/rastertiles/voyager_labels_under/{z}/{x}/{y}{r}.png";
exports.LEAFLET_ATTRIBUTION =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>';

exports.BBOX_COLOR = "#f06eaa";
exports.BBOX_WEIGHT = 5;
exports.BBOX_OPACITY = 0.3;

// reactivesearch retrieves data from each component by its componentId
// custom Reactivesearch component
exports.ID_COMPONENT = "_id";
exports.QUERY_SEARCH_COMPONENT_ID = "query_string";
exports.MAP_COMPONENT_ID = "polygon";

// built in Reactivesearch component id
exports.RESULTS_LIST_COMPONENT_ID = "results";

// fields returned by Elasticsearch (less fields = faster UI)
exports.FIELDS = [
  "starttime",
  "endtime",
  "location",
  "center",
  "urls",
  "browse_urls",
  "datasets",
  "metadata.state",
  "metadata.status",
  "metadata.platform",
  "metadata.sensoroperationalmode",
  "metadata.polarisationmode",
  "metadata.user_tags",
  "@timestamp",
];

exports.GRQ_TABLE_VIEW_DEFAULT = true;

exports.FILTERS = [
  {
    componentId: "dataset",
    dataField: "dataset.keyword",
    title: "Dataset",
    type: "single",
    size: 1000,
  },
  {
    componentId: "dataset_type",
    dataField: "dataset_type.keyword",
    title: "Dataset Type",
    type: "single",
    size: 1000,
  },
  {
    componentId: "dataset_level",
    dataField: "dataset_level.keyword",
    title: "Dataset Level",
    type: "single",
    size: 1000,
  },
  {
    componentId: "system_version",
    dataField: "system_version.keyword",
    title: "System Version",
    type: "single",
    size: 1000,
  },
  {
    componentId: "platform",
    dataField: "metadata.platform.keyword",
    title: "Platform",
    type: "single",
  },
  {
    componentId: "continent",
    dataField: "continent.keyword",
    title: "Continent",
    type: "single",
  },
  {
    componentId: "tags",
    dataField: "metadata.tags.keyword",
    title: "Tags",
    type: "multi",
    size: 1000,
  },
  {
    componentId: "starttime",
    dataField: "starttime",
    title: "Start Time",
    type: "date",
  },
  {
    componentId: "endtime",
    dataField: "endtime",
    title: "End Time",
    type: "date",
  },
  {
    componentId: "state",
    dataField: "metadata.state.keyword",
    title: "State",
    type: "single",
    size: 1000,
  },
];

exports.QUERY_LOGIC = {
  and: [
    "dataset",
    "dataset_level",
    "dataset_type",
    "starttime",
    "platform",
    "continent",
    "endtime",
    "system_version",
    "state",
    "tags",
    this.ID_COMPONENT,
    this.MAP_COMPONENT_ID,
    this.QUERY_SEARCH_COMPONENT_ID,
  ],
};

exports.GRQ_DISPLAY_COLUMNS = [
  {
    Header: "_id",
    accessor: "_id",
    width: 500,
  },
  {
    Header: "ingest_timestamp",
    accessor: "@timestamp",
    width: 200,
  },
  {
    Header: "start_time",
    accessor: "starttime",
  },
  { Header: "end_time", accessor: "endtime" },
  {
    Header: "status",
    accessor: "metadata.status",
  },
  {
    Header: "direction",
    accessor: "metadata.direction",
    width: 100,
  },
  {
    id: "browse",
    width: 100,
    resizable: false,
    Cell: (state) =>
      state.original.urls ? (
        <a
          target="_blank"
          href={state.original.urls[0]}
          rel="noopener noreferrer"
        >
          Browse
        </a>
      ) : null,
  },
];

exports.SORT_OPTIONS = [
  "@timestamp",
  "starttime",
  "endtime",
  "creation_timestamp",
];
