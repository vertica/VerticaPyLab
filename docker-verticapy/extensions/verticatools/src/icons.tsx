import { LabIcon } from '@jupyterlab/ui-components';

import verticapyIconSvg from '../style/icons/verticapy.svg';
import admintoolsIconSvg from '../style/icons/admintools.svg';
import vsqlIconSvg from '../style/icons/vsql.svg';
import verticapylabIconSvg from '../style/icons/verticapylab.svg';
import course1IconSvg from '../style/icons/course1.svg'

export const verticapylabIcon = new LabIcon({
    name: 'vertica:verticapylab',
    svgstr: verticapylabIconSvg
});

export const admintoolsIcon = new LabIcon({
    name: 'vertica:admintools',
    svgstr: admintoolsIconSvg
});

export const vsqlIcon = new LabIcon({
    name: 'vertica:vsql',
    svgstr: vsqlIconSvg
});

export const verticapyIcon = new LabIcon({
    name: 'vertica:verticapy',
    svgstr: verticapyIconSvg
});

export const course1Icon = new LabIcon({
    name: 'vertica:course1',
    svgstr: course1IconSvg
});

