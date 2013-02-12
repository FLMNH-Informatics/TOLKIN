//= require <page>
//= require <chromosome/z_file>

JooseModule('Chromosome.ZFiles', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender:  { is: 'ro', init: true },
      title:      { is: 'ro', init: 'Upload ZVI File' },
      height:     { is: 'ro', init: 195 },
      width:      { is: 'ro', init: 500 },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'new_project_chromosome_z_file_path',
          paramFunc: function () {
            return {
              probe_id: this.params().probe_id
            }
          }
        }, this)
      }}
  },
  methods: {
    onSubmitSuccess: function () {
      this.notifier().success('ZVI File successfully uploaded.');
    },
    onSubmitFailure: function () {
      this.notifier().error('Error encountered uploading ZVI File.');
    }
  }
});
});