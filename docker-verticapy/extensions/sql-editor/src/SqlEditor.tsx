import { ScriptEditor } from '@elyra/script-editor';

import { DocumentRegistry, DocumentWidget } from '@jupyterlab/docregistry';
import { FileEditor } from '@jupyterlab/fileeditor';
import { LabIcon } from '@jupyterlab/ui-components';
import sqlIconSvg from '../style/icons/sql.svg';

export const sqlIcon = new LabIcon({
    name: 'vertica:sqleditor',
    svgstr: sqlIconSvg
  });

export class SqlEditor extends ScriptEditor {
  /**
   * Construct a new Sql Editor widget.
   */
  constructor(
    options: DocumentWidget.IOptions<FileEditor, DocumentRegistry.ICodeModel>
  ) {
    super(options);
  }
  getLanguage(): string {
    return 'sql';
  }

  getIcon(): LabIcon {
    return sqlIcon;
  }
}