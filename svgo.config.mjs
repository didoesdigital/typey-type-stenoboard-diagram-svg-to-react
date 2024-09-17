export default {
  js2svg: {
    indent: 2, // number
    pretty: true, // boolean
  },
  plugins: [
    {
      name: 'preset-default',
      params: {
        overrides: {
          removeUselessStrokeAndFill: true,
          mergePaths: false,
          removeTitle: false,
          removeEmptyContainers: false,
          collapseGroups: false,
          cleanupIds: false,
        },
      },
    },
    'removeDimensions',
  ],
};
