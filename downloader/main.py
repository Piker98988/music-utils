"""
FIXME: de-nest all of the code that's not exported to an outside function...
TODO: better get this running
"""
import sys
import time
from math import floor

from loguru import logger
from playwright.sync_api import sync_playwright


def startLogger():
    # set the logging file and test
    logger.add("./.cache/logs/downloader_{time}.log")
    logger.info("Loguru initiated: info")
    logger.debug("Loguru initiated: debug")
    logger.warning("Loguru initiated: warn")
    logger.error("Loguru initiated: error")
    logger.critical("Loguru initiated: critical")


def is_playlist(url: str):
    """
    very explicit name. if the user inputs a url that leads to a track it will return False,
    because the url containing "track" will be a song and the url containing "playlist" will be a playlist.
    :param url: url to check
    """
    return "track" not in url  # will return true for playlist


def _accept_cookie_popup(page):
    logger.debug("Searching for cookie pop up...")
    cookie_accept = page.get_by_role("button", name="Consent")
    logger.info("Cookie popup found")
    cookie_accept.click()
    logger.info("Cookie pop up accepted")


def _handle_playlist_download(page, zip_number):
    """
    TODO: implement a dynamic song amount catcher instead of asking user for it.

    When called will expect the page to be already set up with the second download button
    for **playlist** downloading. shall not be called from outside main.py unless a page already set up
    is given as argument

    :param page: already opened page
    :param zip_number: zip files to download in case that playlist has >100 songs
    :return:
    """

    logger.debug("Playlist download handler called")
    iterations = 1
    while iterations <= zip_number + 1:
        logger.debug(f"Downloading zip {iterations}")
        # TODO
        iterations += 1
    raise NotImplementedError


def _handle_song_download(page):
    """
    When called will expect the page to be already set up with the second download button
    for **song** downloading. shall not be called from outside main.py unless a page already set up
    is given as argument

    :param page: already opened page
    """
    logger.debug("Song download handler called")

    # search for the second button to download
    logger.debug("Searching for song convert button")
    convert_button = page.get_by_role("button", name="Download")

    # click it
    convert_button.click()
    logger.debug("Convert song button clicked")

    # wait for the song to be converted to mp3
    time.sleep(5)
    logger.debug("Song processed")

    # search for the actual download button
    download_button = page.get_by_role("link", name="Download MP3")
    logger.debug("Download button found")

    with page.expect_download() as download_info:
        download_button.click()
        logger.debug("Download song button clicked")

    song = download_info.value
    logger.debug("Waiting for the song to be downloaded...")
    logger.debug("Checking if download has been complete...")
    song.save_as("./.cache/" + song.suggested_filename)
    logger.info("Download complete")


def main():
    """
    Main function that handles the browser instances and process the url given by the user
    """

    # start the logger and test it using the startLogger() func
    logger.info("------------- Test Logger -------------")
    startLogger()

    # start the main logging
    logger.info("----------------- Main -----------------")
    logger.debug("Capturing url...")

    # capture user url input and log it
    sys.stdout.write("Insert Spotify url to download\n>> ")
    sys.stdout.flush()  # i feel more comfortable using sys.stdout and sys.stdin than print and input, don't judge me
    user_url = sys.stdin.readline().strip()  # strip input from line breaks and trailing spaces
    logger.debug(f"Url captured: {user_url}")

    # start a browser instance
    with sync_playwright() as p:
        logger.info("Starting connection...")

        # open chromium
        browser = p.chromium.launch(headless=False)
        logger.debug("Browser opened")

        # new page in spotifydown.com
        page = browser.new_page()
        logger.debug("Page opened")
        logger.debug("Accessing spotifydown site")
        page.goto("https://spotifydown.com")

        # search for the textbox
        input_textbox = page.get_by_placeholder("https://open.spotify.com/..../....")
        logger.debug("Input textbox found")

        """
        To understand the following code you need to know that spotifydown.com has an anti-bot that records your
        tpm and based on it lets you dowload or not. The workaround is basically selecting the textbox and instead
        of using type() method, which does it letter by letter, use the insert_text() one which pastes it in an instant
        """

        # select textbox
        input_textbox.type("")
        # paste the url
        page.keyboard.insert_text(user_url)
        logger.debug("The user_url has been input into the input_textbox")
        logger.debug(f"is_playlist: {is_playlist(user_url)}")
        logger.debug("Searching for first download button (process url button)")

        # search for download button and click it
        # not anymore...
#        submit_button_1 = page.get_by_role("button", name="Download")
#        logger.info("Process url button found")
#        submit_button_1.click()
#        logger.debug("Process url button clicked")
        page.keyboard.press("Enter")


        logger.debug(f"Calling accept cookie popup")
        _accept_cookie_popup(page)

        # double check whether its a playlist or a song
        if is_playlist(user_url):
            logger.debug("Capturing amount of songs from user...")

            # capture amount of songs in the playlist
            sys.stdout.write("Note: not recommended to download playlists with >100 songs\n")
            sys.stdout.write("How many songs does your playlist have?\n>> ")
            sys.stdout.flush()

            # just in case user does not behave
            while True:
                try:
                    songs_amount = int(sys.stdin.readline().strip())
                    break
                except ValueError:
                    logger.debug("User is a rebel. songs_amount is not an integer; loop still running")
                    sys.stdout.write("Please, input a number.\n>> ")

            # log the amount of songs and calculate the amount of zip files to download
            logger.debug(f"songs_amount is {songs_amount}")
            logger.debug("Calculating amount of zip files that will be downloaded...")
            amount_of_zips = floor(songs_amount / 100 + 1)
            logger.info(f"Amount of zip files to be downloaded: {amount_of_zips}")

            # call the playlist download handler
            logger.debug("calling playlist downloads handler")
            _handle_playlist_download(page, amount_of_zips)
        else:
            # call the song download handler
            logger.debug("calling song downloads handler")
            _handle_song_download(page)

        # close browser end proccess
        logger.info("Playlist downloaded successfully" if is_playlist(user_url) else "Song downloaded successfully")
        logger.debug("Procceeding with unzipping..." if is_playlist(user_url) else "Procceeding with renaming...")
        logger.debug(f"Closing browser...")
        browser.close()
        logger.debug("Browser closed")
        logger.debug("Operation complete")


if __name__ == '__main__':
    main()
