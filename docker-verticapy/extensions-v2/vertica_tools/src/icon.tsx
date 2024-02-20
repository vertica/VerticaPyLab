import { LabIcon } from '@jupyterlab/ui-components';

import verticapyIconSvg from '../style/verticapy.svg';
import queryIconSvg from '../style/query.svg';

export const verticapyIcon = new LabIcon({
    name: 'vertica:verticapyicon',
    svgstr: verticapyIconSvg
});

export const queryIcon = new LabIcon({
    name: 'vertica:queryicon',
    svgstr: queryIconSvg
});