#include "dc_file_browser.h"
#include "dc_utils.h"
#include <strings.h>
#ifndef stricmp
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif


DCFileBrowser::DCFileBrowser()
{
	strcpy(m_dir, "/cd");
	m_menu.user_data = this;
	m_found = false;
	m_deep = 0;
	m_file_path[0] = '\0';
	strcpy(m_highest_dir, "/cd");
	m_has_old_data = false;
	m_default_icon = NULL;
	m_folder_icon = NULL;
	directory_color = 0x11000000;
}

DCFileBrowser::~DCFileBrowser()
{
	for (uint32 k = 0; k < m_icons.size(); ++k)
		delete[] m_icons[k];
}

bool DCFileBrowser::Browse(bool use_last)
{
	m_found = false;
	bool on_highest;
	while (!m_found)
	{
		on_highest = (strcmp(m_highest_dir, m_dir) == 0);
		if (!m_has_old_data || !use_last)
		{
			m_menu.RemoveAllItems();
			++m_deep;
			file_t fpd = fs_open(m_dir, O_DIR | O_RDONLY);
			if (!fpd)
				return false;
			const dirent_t* dirinfo;
			DCMenuItem* itemtemp = NULL;
			char* dotpos = NULL;
			bool found_ext = false;
			while ((dirinfo = fs_readdir(fpd)))
			{
				if (dirinfo->size == -1)
				{
					itemtemp = m_menu.AddItem(dirinfo->name, DCFileBrowser::OnChooseDir);
					itemtemp->color = directory_color;
					if (m_folder_icon)
						itemtemp->SetIcon(m_folder_icon);
				}
				else if (dc_is_rom_extension(dirinfo->name))
					itemtemp = m_menu.AddItem(dirinfo->name, DCFileBrowser::OnChooseFile);
				else
					continue;
				dotpos = strrchr(dirinfo->name, '.');
				if (dotpos)
				{
					found_ext = false;
					for (uint32 k = 0; k < m_icon_extensions.size(); ++k)
					{
						if (stricmp(dotpos, m_icon_extensions[k]) == 0)
						{
							itemtemp->SetIcon(m_default_icon);
							found_ext = true;
							break;
						}
					}
					if (!found_ext && m_default_icon)
						itemtemp->SetIcon(m_default_icon);
				}
				else if (m_default_icon)
					itemtemp->SetIcon(m_default_icon);
			}
			fs_close(fpd);
			m_has_old_data = true;
		}
		use_last = false;
		if (!m_menu.Run())
		{
			if (on_highest)
				break;
			char* pSlash = strrchr(m_dir, '/');
			if (pSlash == NULL)
				break;
			*pSlash = '\0';
		}
	}
	return m_found;
}

void DCFileBrowser::SetDirectory(const char* szdir)
{
	snprintf(m_dir, sizeof(m_dir), "%s", szdir);
}

const char* DCFileBrowser::GetDirectory()
{
	if (strlen(m_dir) == 0)
		return NULL;
	return m_dir;
}

void DCFileBrowser::SetHighestDirecty(const char* szdir)
{
	snprintf(m_highest_dir, sizeof(m_highest_dir), "%s", szdir);
}

const char* DCFileBrowser::GetHighestDirecty()
{
	if (strlen(m_highest_dir) == 0)
		return NULL;
	return m_highest_dir;
}

const char* DCFileBrowser::GetChosenFilePath()
{
	if (strlen(m_file_path) == 0)
		return NULL;
	return m_file_path;
}

void DCFileBrowser::SetIcon(CPVRTexture* icon, const char* extension)
{
	for (uint32 k = 0; k < m_icon_extensions.size(); ++k)
	{
		if (stricmp(m_icon_extensions[k], extension) == 0)
		{
			m_icons[k] = icon;
			return;
		}
	}
	m_icons.push(icon);
	char* sztemp = new char[strlen(extension) + 1];
	strcpy(sztemp, extension);
	m_icon_extensions.push(sztemp);
}

void DCFileBrowser::OnChooseDir(DCMenu* pMenu, DCMenuItem* pMenuItem, int value)
{
	DCFileBrowser* pBrowser = (DCFileBrowser*) pMenu->user_data;
	// Refuse to descend rather than overflow/truncate the path buffer.
	if (strlen(pBrowser->m_dir) + 1 + strlen(pMenuItem->GetText()) + 1 > sizeof(pBrowser->m_dir))
		return;
	strcat(pBrowser->m_dir, "/");
	strcat(pBrowser->m_dir, pMenuItem->GetText());
	pBrowser->m_menu.Stop();
}

void DCFileBrowser::OnChooseFile(DCMenu* pMenu, DCMenuItem* pMenuItem, int value)
{
	DCFileBrowser* pBrowser = (DCFileBrowser*) pMenu->user_data;
	snprintf(pBrowser->m_file_path, sizeof(pBrowser->m_file_path), "%s/%s", pBrowser->m_dir, pMenuItem->GetText());
	pBrowser->m_found = true;
	pBrowser->m_menu.Stop();
}
