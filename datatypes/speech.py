from galaxy.datatypes.text import Text
from galaxy.datatypes.binary import Binary
from galaxy.datatypes.metadata import MetadataElement, MetadataParameter, ListParameter, DictParameter
from galaxy import util

import wave
import re
import os

import logging
log = logging.getLogger(__name__)

class WAV( Binary ):
    """RIFF WAV audio file"""

    file_ext = "wav"
    blurb = "RIFF WAV Audio file"
    is_binary = True

    MetadataElement( name="rate", desc="Sample Rate", param=MetadataParameter, readonly=True, visible=True, optional=True )
    MetadataElement( name="nframes", desc="Number of Samples", param=MetadataParameter, readonly=True, visible=True, optional=True )
    MetadataElement( name="nchannels", desc="Number of Channels", param=MetadataParameter, readonly=True, visible=True, optional=True )
    MetadataElement( name="sampwidth", desc="Sample Width", param=MetadataParameter, readonly=True, visible=True, optional=True )

    def get_mime(self):
        """Returns the mime type of the datatype"""
        return 'audio/wav'

    def sniff(self, filename):
        """
        >>> from galaxy.datatypes.sniff import get_test_fname
        >>> fname = get_test_fname('hello.wav')
        >>> WAV().sniff(fname)
        True

        >>> fname = get_test_fname('drugbank_drugs.cml')
        >>> WAV().sniff(fname)
        False
        """

        try:
            fp = wave.open(filename, 'rb')
            fp.close()
            return True
        except wave.Error:
            return False

    def set_meta( self, dataset, overwrite=True, **kwd ):
        """Set the metadata for this dataset from the file contents
        """

        fd = wave.open(dataset.dataset.file_name, 'rb')
        dataset.metadata.rate = fd.getframerate()
        dataset.metadata.nframes = fd.getnframes()
        dataset.metadata.sampwidth = fd.getsampwidth()
        dataset.metadata.nchannels = fd.getnchannels()
        #dataset.metadata.identifier = os.path.splitext(dataset.dataset.element_identifier)[0]
        fd.close()

    #def display_data(self, trans, dataset, preview=False, filename=None, to_ext=None, offset=None, ck_size=None, **kwd):

    #    return trans.fill_template( "/dataset/audio.mako", dataset=dataset)


Binary.register_sniffable_binary_format('wav', 'wav', WAV)


class TextGrid( Text ):
    """Praat Textgrid file for speech annotations

    >>> from galaxy.datatypes.sniff import get_test_fname
    >>> fname = get_test_fname('1_1119_2_22_001.TextGrid')
    >>> TextGrid().sniff(fname)
    True

    >>> fname = get_test_fname('drugbank_drugs.cml')
    >>> TextGrid().sniff(fname)
    False

    """

    file_ext = "TextGrid"
    header = 'File type = "ooTextFile"\nObject class = "TextGrid"\n'

    blurb = "Praat TextGrid file"

    MetadataElement( name="annotations", default=[], desc="Annotation types", param=ListParameter, readonly=True, visible=True, optional=True, no_value=[] )

    def sniff(self, filename):

        with open(filename, 'r') as fd:
            firstline = fd.readline()
            secondline = fd.readline()

            return firstline+secondline == self.header

        return False

class BPF( Text ):
    """Munich BPF annotation format
    https://www.phonetik.uni-muenchen.de/Bas/BasFormatseng.html#Partitur

    >>> from galaxy.datatypes.sniff import get_test_fname
    >>> fname = get_test_fname('1_1119_2_22_001.par')
    >>> BPF().sniff(fname)
    True

    >>> fname = get_test_fname('drugbank_drugs.cml')
    >>> BPF().sniff(fname)
    False

    """

    file_ext = "par"

    MetadataElement( name="annotations", default=[], desc="Annotation types", param=ListParameter, readonly=True, visible=True, optional=True, no_value=[] )

    def set_meta( self, dataset, overwrite=True, **kwd ):
        """Set the metadata for this dataset from the file contents"""

        types = set()
        with open(dataset.dataset.file_name, 'r') as fd:
            for line in fd:
                match = re.match("([A-Z]+):\s", line)
                if match is None:
                    return False
                types.add(match.group(1))
        dataset.metadata.annotations = list(types)

    def sniff(self, filename):

        with open(filename, 'r') as fd:
            for line in fd:
                match = re.match("([A-Z]+):\s", line)
                return match is not None
        # in case the file is empty
        return False

def _test():
    import doctest
    doctest.testmod()

if __name__ == "__main__":
    _test()
